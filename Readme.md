### Libco源码学习

关于LIBCO 最为详细的入门级学习资源,Word中的文档目录如下：

### 1 说明 
### 2 什么是协程？  
2.1 协程与线程的区别  
2.2 对称协程与非对称协程  
2.3 独占栈与共享栈  
### 3 协程的原理  
3.1 函数调用栈   
3.2 保存&恢复上下文   
3.3 任务调度  
3.3.1 co_resume   
3.3.2 co_yield_ct   
3.3.3 co_swap   
3.4 协程同步   
3.4.1 co_cond_timedwait   
3.4.2 co_cond_signal   
3.4.3 co_cond_broadcast   
3.4.4 co_eventloop   
3.5 其它函数   
3.5.1 Poll   
### 4 数据结构   
4.1 协程环境   
4.2 协程栈空间   
4.3 EPOLL  
4.1 双向链表   
4.2 定时器   
### 5 HOOK机制   
### 6 源码分析   
6.1 EXAMPLE_COND 生产者与消息者示例   
6.2 EXAMPLE_ECHOCLI 异步客户端   
6.3 EXAMPLE_ECHOSVR 搭建一个简单的服务    

```
欢迎技术交流（113172721@qq.com），
