#ifndef GMLFILEPARSER_H
#define GMLFILEPARSER_H

#include "shared/loading/iparser.h"
#include "shared/plugins/userelementdata.h"

class GmlFileParser: public IParser
{
private:
    UserNodeData* _userNodeData;

public:
    explicit GmlFileParser(UserNodeData* userNodeData = nullptr);

    bool parse(const QUrl& url, IGraphModel& graphModel, const ProgressFn& progressFn) override;
};

#endif // GMLFILEPARSER_H
