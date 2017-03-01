#ifndef TEXTVISUALISATIONCHANNEL_H
#define TEXTVISUALISATIONCHANNEL_H

#include "visualisationchannel.h"

class TextVisualisationChannel : public VisualisationChannel
{
public:
    using VisualisationChannel::VisualisationChannel;

    void apply(double value, ElementVisual& elementVisual) const;
    void apply(const QString& value, ElementVisual& elementVisual) const;

    bool supports(FieldType fieldType) const { return fieldType != FieldType::Unknown; }
    bool requiresNormalisedValue() const { return false; }

    QString description(ElementType, FieldType) const;
};

#endif // TEXTVISUALISATIONCHANNEL_H
