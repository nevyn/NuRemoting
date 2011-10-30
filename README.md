NuRemote
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

The fun stuff doesn't end there. I've built a "pretty" GUI application you can use to do your remote scripting in, confusingly called NuRemoter.

<img src="http://f.cl.ly/items/0o0e3z0h3t2T1V422V1x/Screen%20Shot%202011-10-30%20at%2022.24.40.png" />

If you plug things in the right way, you even get your console log messages warped in through hyperspace.

(Secret magic: the ugly combo box at the top allows you to load and save code snippets, that end up cluttering your Documents folder. You can also do "#require foobar" to include the snippet 'foobar' into the current one, e g for setting up commonly used state).