#include "applytransformationscommand.h"

#include <QObject>

#include "graph/graphmodel.h"
#include "ui/selectionmanager.h"
#include "ui/document.h"

ApplyTransformationsCommand::ApplyTransformationsCommand(GraphModel* graphModel,
                                                         SelectionManager* selectionManager, Document* document,
                                                         const QStringList& previousTransformations,
                                                         const QStringList& transformations) :
    _graphModel(graphModel),
    _selectionManager(selectionManager),
    _document(document),
    _previousTransformations(previousTransformations),
    _transformations(transformations),
    _selectedNodeIds(_selectionManager->selectedNodes())
{}

QString ApplyTransformationsCommand::description() const
{
    return QObject::tr("Apply Transformations");
}

QString ApplyTransformationsCommand::verb() const
{
    return QObject::tr("Applying Transformations");
}

void ApplyTransformationsCommand::doTransform(const QStringList& transformations)
{
    _graphModel->buildTransforms(transformations);

    // This needs to happen on the main thread
    QMetaObject::invokeMethod(_document, "setTransforms", Q_ARG(const QStringList&, transformations));
}

bool ApplyTransformationsCommand::execute()
{
    doTransform(_transformations);
    return true;
}

void ApplyTransformationsCommand::undo()
{
    doTransform(_previousTransformations);

    // Restore the selection to what it was prior to the transformation
    _selectionManager->selectNodes(_selectedNodeIds);
}
