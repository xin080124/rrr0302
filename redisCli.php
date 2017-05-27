
#type the following line by line#
SET foo 10
INCR foo
INCR foo
INCR foo

HMSET user:1 username runoob password runoob points 200
HGETALL user:1


redis> HMSET myhash field1 "Hello" field2 "World"
OK
redis> HGET myhash field1
"Hello"
redis> HGET myhash field2
"World"
redis> 

//java interface
 Map<String, String> map = new HashMap<String, String>();
        map.put("name", "fujianchao");
        map.put("password", "123");
        map.put("age", "12");
        // 存入一个map
        jedis.hmset("user", map);

redis 127.0.0.1:6379> ZADD myset 1 "hello"
(integer) 1
redis 127.0.0.1:6379> ZADD myset 1 "foo"
(integer) 1
redis 127.0.0.1:6379> ZADD myset 2 "world" 3 "bar"
(integer) 2
redis 127.0.0.1:6379> ZRANGE myzset 0 -1 WITHSCORES
1) "hello"
2) "1"
3) "foo"
4) "1"
5) "world"
6) "2"
7) "bar"
8) "3"
		
		

##################################################

include("retwis.php");

# Form sanity checks
if (!gt("username") || !gt("password"))
    goback("You need to enter both username and password to login.");

# The form is ok, check if the username is available
$username = gt("username");
$password = gt("password");
$r = redisLink();
$userid = $r->hget("users",$username);
if (!$userid)
    goback("Wrong username or password");
$realpassword = $r->hget("user:$userid","password");
if ($realpassword != $password)
    goback("Wrong useranme or password");

# Username / password OK, set the cookie and redirect to index.php
$authsecret = $r->hget("user:$userid","auth");
setcookie("auth",$authsecret,time()+3600*24*365);
header("Location: index.php");

##################################################
remove all db:
flushall



