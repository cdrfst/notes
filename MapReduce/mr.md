# 标题1

## 思路：

1.把所有文件数据整体升序排列,直接利用mr对key的默认排序功能

1.1.但通过将Text类型的数据直接输出后发现并没有按预期排序，发现Text虽然实现了WritableComparable接口，但其是按字典排序的，所以在Mapper里将数据转换为Integer类型后输出:

![image-20210513125224642](images\image-20210513125224642.png)

2.在Reducer里得到的就是排序后的结果了,因为key有重复的所以需要遍历values来拿到所有key,再加上一个自增变量当成序号列,按需求列顺序输出

![image-20210513125725560](images\image-20210513125725560.png)

3.保证reduceTask数量是1个(默认) END
