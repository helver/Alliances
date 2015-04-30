<?php
/**
 * constantsDefinition.inc
 * Author: Marie Roux
 *
 * Description:
 * contains the declaration of constants and methods
 * that are used in the project
 *
 * Revision: $Revision: 1.40 $
 * Last Change Date: $Date: 2004-03-22 21:06:15 $
 * Last Editor: $Author: eric $
 */


// list the pages that should not been updated, inserted, or deleted
$viewOnlyPages = array("tid_history" => 1, "light_level" => 1, "alarm_ticket" => 1,
                        "alarm" => 1);

// list of the pages that require a date in the search
$datePages = array(
                    "tid_history" => array ("format" => "MM/DD HH24:MI",
                                            "DBfield" => "t.timeEntered"
                                           ),
                    "light_level" => array ("format" => "MM/DD",
                                            "DBfield" => "t.dayEntered"
                                           )
                  );


// used for the search in the case of tid_history
$startEndDateArray = array ("start_date" => "Start Date GMT",
                            "end_date"   => "End Date GMT" );


 $sev = array( "r" => 1,
               "y" => 2,
               "g" => 3,
               "n" => 4,
               "t" => 5,
               "e" => 6,
               "R" => 0,
             );


 ///////////////////////////////////
// FUNCTIONS
//////////////////////////////////

/**
 * check the validity of the inputs
 * @param $cols the value of the inputs
 * @param $recordNum the index of the record to check
 * @param $dbh the database handler
 * @param $table the table name */
function checkEntries($cols, $recordNum, $dbh, $table)
{
  print("Using checkEntries from constantsDefinition.inc<br>\n");
  exit();

  global $pageType;

  // check for duplicate names in the index tables
  if ($pageType == "customer" || $pageType == "facility" || $pageType == "protocol" || $pageType == "receive_channel" || $pageType == "element_type")
  {
    unset($exist);
    $exist = $dbh->select($table."id", "$table", "$table = '" . $cols[strtoupper($table)] . "' and " . $table."id <> $recordNum");
    if ($exist[0]) { return "Entry failed: the ".strtoupper($table)." ". $cols[strtoupper($table)]. " already exists in the record ".$exist[0][0]."."; }
    else { return; }
  }

  return;
}

function isValidDate($year, $month, $day, $hour = 0, $minutes = 0, $secondes = 0)
{
  print("Using isValidDate from constantsDefinition.inc<br>\n");
  exit();

  // year between 0 and 32,767
  // month between 1 and 12
  // day is within the allowable days of that month
  if (checkdate($month, $day, $year))
  {
    if ($hour >= 0 && $hour < 24
        && $minutes >= 0 && $minutes < 60
        && $secondes >= 0 && $secondes < 60
       )
    {
      return 1;
    }
  }
  else
  {
    return 0;
  }
}


?>