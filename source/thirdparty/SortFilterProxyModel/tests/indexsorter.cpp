#include "indexsorter.h"
#include <QtQml>

int IndexSorter::compare(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
    return sourceLeft.row() - sourceRight.row();
}

int ReverseIndexSorter::compare(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
    return sourceRight.row() - sourceLeft.row();
}

void registerIndexSorterTypes() {
    qmlRegisterType<IndexSorter>("SortFilterProxyModel.Test", 0, 2, "IndexSorter");
    qmlRegisterType<ReverseIndexSorter>("SortFilterProxyModel.Test", 0, 2, "ReverseIndexSorter");
}

Q_COREAPP_STARTUP_FUNCTION(registerIndexSorterTypes)
