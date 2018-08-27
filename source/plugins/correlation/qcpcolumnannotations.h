#ifndef QCPCOLUMNANNOTATIONS_H
#define QCPCOLUMNANNOTATIONS_H

#include "thirdparty/qcustomplot/qcustomplot_disable_warnings.h"
#include "thirdparty/qcustomplot/qcustomplot.h"
#include "thirdparty/qcustomplot/qcustomplot_enable_warnings.h"

#include "columnannotation.h"

#include <QColor>
#include <QRect>

#include <vector>
#include <map>

class QCPColumnAnnotations : public QCPAbstractPlottable
{
    Q_OBJECT

private:
    struct Row
    {
        Row(std::vector<size_t> indices, bool selected,
            const ColumnAnnotation* columnAnnotation) :
            _indices(std::move(indices)), _selected(selected),
            _columnAnnotation(columnAnnotation)
        {}

        std::vector<size_t> _indices;
        bool _selected = true;
        const ColumnAnnotation* _columnAnnotation;
    };

    std::map<size_t, Row> _rows;

public:
    explicit QCPColumnAnnotations(QCPAxis *keyAxis, QCPAxis *valueAxis);

    double selectTest(const QPointF& pos, bool onlySelectable, QVariant* details = 0) const override;
    QCPRange getKeyRange(bool& foundRange, QCP::SignDomain inSignDomain = QCP::sdBoth) const override;
    QCPRange getValueRange(bool& foundRange, QCP::SignDomain inSignDomain = QCP::sdBoth,
        const QCPRange& inKeyRange = QCPRange()) const override;

    void setData(size_t y, std::vector<size_t> indices, bool selected,
        const ColumnAnnotation* columnAnnotation);

protected:
    void draw(QCPPainter* painter) override;
    void drawLegendIcon(QCPPainter* painter, const QRectF &rect) const override;

private:
    void renderRect(QCPPainter* painter, size_t x, size_t y, size_t w, QColor color);
};

#endif // QCPCOLUMNANNOTATIONS_H
