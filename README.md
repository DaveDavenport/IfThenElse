# Description:

IfThenElse is a simple program used to glue small unix tools together with the ultimate goal to automate some tedious tasks.

The structure off an IfThenElse chain is as follow: Trigger -> Check -> [Then] Action1 | [Else] Action2

For example a chain could be:

    Trigger: Every minute
    Check: Is a Movie Playing
    Then: Turn off the light
    Else: Turn on the light

This should result the light turning off when starting the movie, and on when the movie is finished.

Each IfThenElse chain is an action in itself and can be chained up.

## File format

A chain is described in it own file using the ini format. The above example would look like:

    [Trigger]
    type=TimerTrigger
    timeout=60
    action=Check

    [Check]
    type=ExternalToolCheck
    cmd=check_movies.sh
    true_status=1
    false_status=0
    compare_old_state=true
    then_action=Then
    else_action=Else

    [Then]
    type=ExternalToolAction
    cmd=switch_off_lights.sh

    [Else]
    type=ExternalToolAction
    cmd=switch_on_lights.sh

As you can see all it does is to tie external tools together. If you want to use multiple triggers, or drive multiple actions you have to use the MultiCombine node in between to combine the different inputs, or the MultiAction to drive multiple actions.

So say that we want to turn_off the lights and put gajim in offline mode:

    [Trigger]
    type=TimerTrigger
    timeout=60
    action=Check

    [Check]
    type=ExternalToolCheck
    cmd=check_movies.sh
    true_status=1
    false_status=0
    compare_old_state=true
    then_action=ThenMulti
    else_action=Else

    [ThenMulti]
    type=MultiAction
    action=Then1;Then2

    [Then1]
    type=ExternalToolAction
    cmd=switch_off_lights.sh

    [Then2]
    type=ExternalToolAction
    cmd=gajim-remote change_status offline

    [Else]
    type=ExternalToolAction
    cmd=switch_on_lights.sh

This way, it is easy to make complex chains.

## Using the program

Run the program:

    ifthenelse <list of input files>

If you want to generate a dot graph:

    ifthenelse -d output.dot <list of intput files>

If you want to background IfThenElse.

    ifthenelse -b <list of intput files>

If a directory is passed it will, recursively, scan that directory for .ife files.

To stop the program send it a TERM/HUP/INT signal (e.g. press ctrl-c)

To force it to reload the input files send it a USR1 signal.
