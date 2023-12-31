# Aborting a running sentence:

To **break** is to abort the execution of a sentence, without killing
the process.

In jconsole and the web version hitting ctrl-c *while a sentence
executes* sends the break signal. Hitting ctrl-c in jconsole while no
sentence executes, terminates the process.

To break from a different session, for example when the target session
became unresponsive, the target session needs to have a so called
breakfile in `jpath '~user/break'` (check whether one appears there when
staring the session).

If no breakfile exists, it can be created (obviously only before the
session hangs) by running `setbreak 'foo'` in the relevant session,
which tags the session as "foo".

Then, abort the running sentence in this session by calling `break
'foo'` from another J session. By default JQt creates a breakfile
"default" which can be triggered without having to name it (`break ''`).
Jconsole sessions do not have a breakfile by default.

In my experience it might be necessary to send the break signal
repeatedly sometimes (regardless of whether ctrl-c or a break-file is
used).
