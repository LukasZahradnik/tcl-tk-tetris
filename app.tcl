package require Tk

set TABLE_WIDTH 10
set TABLE_HEIGHT 20

set QUEUE_LEN 3

set CELL_SIZE 20

set table {}
set queue {}

set current_shape 0
set pos_x 0
set pos_y 0
set score 0

set colors {
    "black" "yellow" "cyan" "lawn green" "orange red" "cornflower blue" "orange" "orchid"
}

set shapes { 
    {
        {0 0 0 0}
        {0 1 1 0}
        {0 1 1 0}
        {0 0 0 0}
    } {
        {0 0 2 0}
        {0 0 2 0}
        {0 0 2 0}
        {0 0 2 0}
    } {
        {0 0 0 0}
        {0 0 3 3}
        {0 3 3 0}
        {0 0 0 0}
    } {
        {0 0 0 0}
        {0 4 4 0}
        {0 0 4 4}
        {0 0 0 0}
    } {
        {0 0 0 0}
        {0 5 5 0}
        {0 0 5 0}
        {0 0 5 0}
    } {
        {0 0 0 0}
        {0 6 6 0}
        {0 6 0 0}
        {0 6 0 0}
    } {
        {0 0 0 0}
        {0 7 7 7}
        {0 0 7 0}
        {0 0 0 0}
    }
}

proc rotate {arr} {
    set tmp $arr

    for {set i 0} {$i < 4} {incr i} {
        for {set j 0} {$j < 4} {incr j} {
            lset tmp $j [expr {-$i + 3}] [lindex $arr $i $j]
        }
    }

    return $tmp
}

proc check_position {arr pos_x pos_y} {
    global TABLE_HEIGHT TABLE_WIDTH table
    for {set i 0} {$i < 4} {incr i} {
        set y [expr {$pos_y + $i}]
        if {$y >= 0} {
            for {set j 0} {$j < 4} {incr j} {
                if {[lindex $arr $i $j] != 0} {
                    set x [expr {$pos_x + $j}]
                    if {$x < 0 || $x >= $TABLE_WIDTH} {
                        return 0
                    }

                    if {$y >= $TABLE_HEIGHT} {
                        return 0
                    }
                    
                    if {[lindex $table $y $x] != 0} {
                        return 0
                    }
                }
            }
        }
    }

    return 1
}

proc change_position {dx dy} {
    global pos_x pos_y current_shape

    set x [expr {$pos_x + $dx}]
    set y [expr {$pos_y + $dy}]

    if {[check_position $current_shape $x $y]} {
        set pos_x $x
        set pos_y $y
    }

    draw_selected 
}

proc draw_bg {} {
    global TABLE_HEIGHT TABLE_WIDTH CELL_SIZE QUEUE_LEN
    for {set i 0} {$i < $TABLE_HEIGHT} {incr i} {
        set y [expr {$i * $CELL_SIZE}]
        for {set j 0} {$j < $TABLE_WIDTH} {incr j} {
            set x [expr {$j * $CELL_SIZE}]
            .frame.board create rect $x $y [expr {$x + $CELL_SIZE}] [expr {$y + $CELL_SIZE}] -fill "midnight blue"
        }
    }

    for {set i 0} {$i < [expr {($QUEUE_LEN * 5 * 2)}]} {incr i} {
        set y [expr {$i * $CELL_SIZE}]
        for {set j 0} {$j < 5} {incr j} {
            set x [expr {$j * $CELL_SIZE}]
            .frame.ui.queue create rect $x $y [expr {$x + $CELL_SIZE}] [expr {$y + $CELL_SIZE}] -fill "midnight blue"
        }
    }
}

proc draw_selected {} {
    global CELL_SIZE pos_x pos_y current_shape colors

    .frame.board delete brick
    for {set i 0} {$i < 4} {incr i} {
        set y [expr {($i + $pos_y) * $CELL_SIZE}]
        for {set j 0} {$j < 4} {incr j} {
            set val [lindex $current_shape $i $j]
            if {$val != 0} {
                set x [expr {($j + $pos_x) * $CELL_SIZE}]
                .frame.board create rect $x $y [expr {$x + $CELL_SIZE}] [expr {$y + $CELL_SIZE}] -fill [lindex $colors $val] -tags brick
            }
        }
    }
}

proc draw_board {} {
    global TABLE_HEIGHT TABLE_WIDTH CELL_SIZE table colors
    .frame.board delete board

    for {set i 0} {$i < $TABLE_HEIGHT} {incr i} {
        set y [expr {$i * $CELL_SIZE}]
        for {set j 0} {$j < $TABLE_WIDTH} {incr j} {
            set val [lindex $table $i $j]
            if {$val != 0} {
                set x [expr {$j * $CELL_SIZE}]
                .frame.board create rect $x $y [expr {$x + $CELL_SIZE}] [expr {$y + $CELL_SIZE}] -fill [lindex $colors $val] -tags board
            }
        }
    }
}

proc startup {} {
    global TABLE_HEIGHT TABLE_WIDTH QUEUE_LEN
    global shapes table pos_x pos_y current_shape score queue

    set tmp {}
    for {set j 0} {$j < $TABLE_WIDTH} {incr j} {lappend tmp 0}

    lset table {}
    for {set i 0} {$i < $TABLE_HEIGHT} {incr i} {
        lappend table $tmp
    }

    lset queue {}
    for {set i 0} {$i < $QUEUE_LEN} {incr i} {
        lappend queue [expr {int(rand()*7)}]
    }

    puts $queue

    set current_shape [lindex $shapes [expr {int(rand()*7)}]]
    set pos_x 2
    set pos_y -4
    set score 0

    draw_board
    draw_selected
    draw_queue
}

proc draw_queue {} {
    global TABLE_HEIGHT TABLE_WIDTH CELL_SIZE QUEUE_LEN
    global queue colors shapes

    .frame.ui.queue delete queue

    for {set k 0} {$k < $QUEUE_LEN} {incr k} {
        for {set i 0} {$i < 4} {incr i} {
            set y [expr {($k * 5 + $i + 1) * $CELL_SIZE}]
            
            for {set j 0} {$j < 4} {incr j} {
                set val [lindex $shapes [lindex $queue $k] $i $j]
                if {$val != 0} {
                    set x [expr {$j * $CELL_SIZE}]
                    .frame.ui.queue create rect $x $y [expr {$x + $CELL_SIZE}] [expr {$y + $CELL_SIZE}] -fill [lindex $colors $val] -tags queue
                }
            }

        }
    }
}

proc update {} {
    global TABLE_WIDTH TABLE_HEIGHT
    global pos_x pos_y current_shape colors table shapes score queue
    set tmp_y $pos_y

    change_position 0 1

    if {$tmp_y == $pos_y} {
        for {set i 0} {$i < 4} {incr i} {
            set tmp_y [expr {$i + $pos_y}]
            for {set j 0} {$j < 4} {incr j} {
                set val [lindex $current_shape $i $j]
                if {$val != 0} {
                    if {$tmp_y >= 0} {
                        set tmp_x [expr {$j + $pos_x}]
                        lset table $tmp_y $tmp_x $val
                    } else {                    
                        set answer [tk_messageBox -title "Game Over" -message "Score: $score\nRestart game?" -type yesno -icon question]
                        switch -- $answer {
                            yes {
                                startup
                                update
                            }
                            no exit
                        }
                        return
                    }
                }
            }
        }

        set tmp {}
        for {set j 0} {$j < $TABLE_WIDTH} {incr j} {
            lappend tmp 0
        }

        set mult 0
        for {set i 0} {$i < $TABLE_HEIGHT} {incr i} {
            set full 1
            for {set j 0} {$j < $TABLE_WIDTH} {incr j} {
                if {![lindex $table $i $j]} {
                    set full 0
                    break
                }
            }

            if {$full} {
                incr mult
                set table [linsert [lreplace $table $i $i] 0 $tmp]
            }
        }

        set score [expr {$score + $mult * $mult * 100}]

        set pos_y -4
        set pos_x 2

        lappend queue [expr {int(rand()*7)}]
        set current_shape [lindex $shapes [lindex $queue 0]]
        set queue [lreplace $queue 0 0]

        draw_queue
        draw_board
        draw_selected
    }

    if {1} {
        if {$score > 10000} {
            set time 120
        } else {
            set time [expr {int(600 - ($score / 10000.0) * 480)}]
        }

        after $time [list update]
    }
}

proc main {} {
    global TABLE_HEIGHT TABLE_WIDTH CELL_SIZE QUEUE_LEN
    global current_shape pos_x pos_y table

    wm title . "Tetris"
    wm geometry . 400x800

    grid [frame .frame ] -column 0 -row 0
    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1


    grid [canvas .frame.board -width [expr {$TABLE_WIDTH * $CELL_SIZE}] -height [expr {$TABLE_HEIGHT * $CELL_SIZE}] -background black] -row 0 -column 0
    grid [frame .frame.ui -width 100] -row 0 -column 1
    grid [canvas .frame.ui.queue -width [expr {5 * $CELL_SIZE}] -height [expr {($QUEUE_LEN * 5 + 2) * $CELL_SIZE }] -background black] -row 0 -column 0
    grid [label .frame.ui.scorelabel -text "Score:"] -row 1 -column 0
    grid [label .frame.ui.score -textvariable score] -row 2 -column 0

    bind . <Left> {change_position -1 0}
    bind . <Right> {change_position 1 0}
    bind . <Down> {change_position 0 1}
    bind . <Up> {
        set tmp [rotate $current_shape]
        if {[check_position $tmp $pos_x $pos_y]} {
            set current_shape $tmp
        }

        draw_selected
    }

    draw_bg
    startup
    update
}

main 
