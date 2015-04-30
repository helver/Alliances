# Configurations:
set indir {C:\tmp}
set outdir {c:\tmp}

# End of configs.

cd $indir
set gotls 0
set debug 1
set tcl_precision 17
if {[info exists numer]} {
    unset numer
}
if {[info exists denom]} {
    unset denom
}

foreach fl [glob "MAG????.txt"] {
    set input_f [open "$indir\\$fl" r]
    set output_f [open "$outdir\\$fl.out" w]
    #close $output_f
    #set output_f stdout
    set count 0
    if {[info exists time]} { unset time }
    while {[gets $input_f line] >= 0} {
        if {[info exists time]} {} else {
            regexp {^INTERVAL[ \t]+: [a-zA-Z]+[ \t]+([0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9] THRU [0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9])} $line chunk time
            puts $output_f "$time\n\n-------------------------\n"
        }
        if {[regexp {^OM GROUP} $line]} {
            regexp {^OM GROUP[ \t]+:[ \t]+([^ \t]+)} $line trash group
            puts $output_f "OM GROUP: $group"
        }
        if {[regexp {^COMPONENT} $line]} {
            gets $input_f
            gets $input_f line
            if {[info exists labels]} { set labels "" }
            while {[regexp {^[^-]} $line]} {
                regsub -all {[ \t]+} $line " " line
                append labels $line
                gets $input_f line
            }
            regsub {^[ \t]*} $labels "" labels
            #puts "Found labels: $labels"
        }
        if {[regexp {^LS} $line]} {
            #if {$debug} { puts "Found an LS" }
            set gotls 1
            regsub {[ \t]+} $line "-" line
            #puts "$line"
            while {[regexp {[0-9]} $line]} {
                regsub -all {[ \t]+} $line " " line
                append curval $line
                gets $input_f line
            }
            #puts "$curval"
            lappend vals $curval
            set curval ""
        }
        if {[regexp {^GRAND} $line]} {
            if {$gotls != 1} {
                regsub {^GRAND TOTAL} $line "" line
                if {[info exists vals]} { set vals "" }
                while {[regexp {[0-9]} $line]} {
                    regsub -all {[ \t]+} $line " " line
                    append vals $line
                    gets $input_f line
                }
                regsub {^[ \t]*} $vals " " vals
                #puts "Found totals: $vals"
                set count [llength $vals]
                for {set i 0} {$i < $count} {incr i} {
                    puts $output_f [format "%-8s : %d" [lindex $labels $i] [lindex $vals $i]]
                }
                if {[info exists numer]} {
                    set denom [eval expr [join $vals "+"]]
                    #puts "Denom -- $denom"
                } else {
                    set numer [eval expr [join $vals "+"]]
                    #puts "Numer -- $numer"
                }
                set vals ""
            } else {
                set myformat "%-9s"
                for { set i 0 } { $i < [llength $labels] } { incr i } {
                    append myformat "%9s"
                }
                #puts "$myformat"
                set cmd "\[format \"$myformat\" \"\" \"[join $labels "\" \""]\" \]"
                #puts "$cmd"
                puts $output_f [eval format "\"$myformat\"" "\"\"" $labels]
                foreach ln $vals {
                    puts $output_f [eval format "\"$myformat\"" $ln ]
                }
                set vals ""
            }
            set gotls 0
            if {[info exists numer]} {
                #unset numer
            }
            if {[info exists denom]} {
                #unset denom
            }
            puts $output_f "\n-------------------------\n"
        }
        if {[regexp {^SWITCH [^T]} $line]} {
            regexp {CLLI:[ \t]+([A-Za-z0-9]+)} $line trash clli
            puts $output_f "CLLI Code : $clli\n"
        }
        #incr count
        #if {$count > 2000} {
        #    break
        #}
    }
    
    puts $output_f [format "Ratio of table 2 to table 1: %21.17f" [expr [expr $numer * 1.0] / [expr $denom * 1.0]]]
    close $output_f
    close $input_f
}
#exit