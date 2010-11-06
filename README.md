NuRemoting
==========

Put AsyncSocket, SPNuRemote and Nu.framework into your Mac or iOS project, do [[SPNuRemote new] run] somewhere, and suddenly you have magical powers. Say you did this to the standard Window+CoreData project in Xcode (as seen in the "iOS" folder in this repo), and then used your magic wand:

    22:49:14 nevyn:~$ cat magic.nu
    (set a 3)
    (log "Hello #{a}")
    (((((UIApplication sharedApplication) delegate) navigationController) topViewController) insertNewObject)
    (+ a 5)

    22:49:16 nevyn:~$ nc -v 192.168.10.152 8023 < magic.nu 
    Connection to 192.168.10.152 8023 port [tcp/*] succeeded!
    200 OK	8
    
    22:51:01 nevyn:~$

The system log now contains "Hello 3", the table view contains a new row, and you calculated 3 + 5 the hardest way you could think of.

(The Nu.framework is roughly bdf87c923985d from [timburk's repo](https://github.com/timburks/nu), plus some lipo)