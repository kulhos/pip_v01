/opt/pip_V01/mtm_V2.4.5/mtmapi.sl
ClConnect: void ClConnect(I:char *,IO:long *)
ClDisconnect: void ClDisconnect(IO:long *)
ClExchmsg: void ClExchmsg(IO:string *,IO:string *,I:long,IO:long *)
ClSendMsg: void ClSendMsg(IO:string *,I:long,IO:long *)
ClGetMsg: void ClGetMsg(IO:string *,I:long,IO:long *)
SrvConnect: void SrvConnect(I:char *,IO:long *,IO:long *)
SrvDisconnect: void SrvDisconnect()
SrvGetMsg: void SrvGetMsg(IO:string *,I:long,IO:long *)
SrvReply: void SrvReply(IO:string *,IO:long *)
SrvMTMId: void SrvMTMId(I:char *,IO:string *)
MTMCntrl: void MTMCntrl(IO:char *,IO:string *,I:char *,IO:char **,IO:long *)
MTMRunning: void MTMRunning(I:char *,O:long *)
