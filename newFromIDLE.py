import pycassa
import time
con = pycassa.ConnectionPool('History',server_list=["127.0.0.1:9042"]
batch_size = 100
cf = pycassa.ColumnFamily(con,cfName)
cf.insert('row_key',{'col_name':'col_val'})
