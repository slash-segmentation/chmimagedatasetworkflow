#!/usr/bin/env bats

load test_helper

#
# Test 
#
@test "Successful run" {
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath


  mkdir -p "$THE_TMP/input/data"
  echo "hi" > "$THE_TMP/input/data/foo.png"
  echo "hi" > "$THE_TMP/input/data/foo2.png"
  echo "hi" > "$THE_TMP/input/data/foo3.png"
  
  echo "0,images/040.png[39] PNG 500x500 17387x17422+1412+1971 8-bit PseudoClass 256c 200kb,," > "$THE_TMP/bin/command.tasks"
  
  
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -inputPathRaw "$THE_TMP/input" -identifyCmd "$THE_TMP/bin/command" -CWS_outputdir $THE_TMP $WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

  # Verify we got a workflow failed txt file
  [ ! -e "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run grep "Selected input Path: " "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "Selected input Path: $THE_TMP/input/data" ]

  # Check output of workflow.status file
  [ -s "$THE_TMP/$WORKFLOW_STATUS" ]
  run cat "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "# Seconds since"* ]]
  [[ "${lines[1]}" == "time="* ]]
  [ "${lines[3]}" == "phase=Done" ]

  [ -e "$THE_TMP/data/foo.png" ]
  [ -e "$THE_TMP/data/foo2.png" ]
  [ -e "$THE_TMP/data/foo3.png" ] 

  # verify we hardlinked the data 
  run stat --format="%h" "$THE_TMP/data/foo.png"
  [ "$status" -eq 0 ] 
  [ "${lines[0]}" == "2" ]

  run stat --format="%h" "$THE_TMP/data/foo2.png"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "2" ]

  run stat --format="%h" "$THE_TMP/data/foo3.png"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "2" ]





  
}


