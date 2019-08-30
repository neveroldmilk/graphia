#include "betweennesstransform.h"

#include "transform/transformedgraph.h"
#include "graph/graphmodel.h"

#include "shared/graph/grapharray.h"
#include "shared/utils/threadpool.h"

#include <cstdint>
#include <stack>
#include <queue>
#include <map>
#include <thread>

void BetweennessTransform::apply(TransformedGraph& target) const
{
    target.setPhase(QStringLiteral("Betweenness"));
    target.setProgress(0);

    const auto& nodeIds = target.nodeIds();
    const auto& edegIds = target.edgeIds();
    std::atomic_int progress(0);

    struct BetweennessArrays
    {
        explicit BetweennessArrays(TransformedGraph& graph) :
            nodeBetweenness(graph, 0.0),
            edgeBetweenness(graph, 0.0)
        {}

        NodeArray<double> nodeBetweenness;
        EdgeArray<double> edgeBetweenness;
    };

    std::vector<BetweennessArrays> betweennessArrays(
        std::thread::hardware_concurrency(),
        BetweennessArrays{target});

    concurrent_for(nodeIds.begin(), nodeIds.end(),
    [&](const NodeId nodeId, size_t threadIndex)
    {
        auto& arrays = betweennessArrays.at(threadIndex);
        auto& _nodeBetweenness = arrays.nodeBetweenness;
        auto& _edgeBetweenness = arrays.edgeBetweenness;

        // Brandes algorithm
        NodeArray<std::vector<NodeId>> predecessors(target);
        NodeArray<int64_t> sigma(target, 0);
        NodeArray<int64_t> distance(target, -1);
        NodeArray<double> delta(target, 0.0);

        std::stack<NodeId> stack;
        std::queue<NodeId> queue;

        sigma[nodeId] = 1.0;
        distance[nodeId] = 0;
        queue.push(nodeId);

        while(!queue.empty())
        {
            auto other = queue.front();
            queue.pop();
            stack.push(other);

            for(auto neighbour : target.neighboursOf(other))
            {
                if(distance[neighbour] < 0)
                {
                    queue.push(neighbour);
                    distance[neighbour] = distance[other] + 1;
                }

                if(distance[neighbour] == distance[other] + 1)
                {
                    sigma[neighbour] += sigma[other];
                    predecessors[neighbour].push_back(other);
                }
            }
        }

        if(cancelled())
            return;

        while(!stack.empty())
        {
            auto other = stack.top();
            stack.pop();

            for(auto predecessor : predecessors[other])
            {
                auto d = (static_cast<double>(sigma[predecessor]) /
                    static_cast<double>(sigma[other])) * (1.0 + delta[other]);

                auto edgeIds = target.edgeIdsBetween(predecessor, other);
                for(auto edgeId : edgeIds)
                    _edgeBetweenness[edgeId] += d;

                delta[predecessor] += d;
            }

            if(other != nodeId)
                _nodeBetweenness[other] += delta[other];
        }

        progress++;
        target.setProgress(progress.load() * 100 / static_cast<int>(target.numNodes()));

        if(cancelled())
            return;
    });

    target.setProgress(-1);

    if(cancelled())
        return;

    NodeArray<double> nodeBetweenness(target, 0.0);
    EdgeArray<double> edgeBetweenness(target, 0.0);
    for(const auto& arrays : betweennessArrays)
    {
        for(auto nodeId : nodeIds)
            nodeBetweenness[nodeId] += arrays.nodeBetweenness[nodeId];

        for(auto edgeId : edegIds)
            edgeBetweenness[edgeId] += arrays.edgeBetweenness[edgeId];
    }

    _graphModel->createAttribute(QObject::tr("Node Betweenness"))
        .setDescription(QObject::tr("A node's betweenness is the number of shortest paths that pass through it."))
        .setFloatValueFn([nodeBetweenness](NodeId nodeId) { return nodeBetweenness[nodeId]; })
        .setFlag(AttributeFlag::VisualiseByComponent);

    _graphModel->createAttribute(QObject::tr("Edge Betweenness"))
        .setDescription(QObject::tr("An edge's betweenness is the number of shortest paths that pass through it."))
        .setFloatValueFn([edgeBetweenness](EdgeId edgeId) { return edgeBetweenness[edgeId]; })
        .setFlag(AttributeFlag::VisualiseByComponent);
}

std::unique_ptr<GraphTransform> BetweennessTransformFactory::create(const GraphTransformConfig&) const
{
    return std::make_unique<BetweennessTransform>(graphModel());
}
