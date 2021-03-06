#!/usr/bin/env bats

load test_helper

#
# Test 
#
@test "png files in data subdir but hard link fails" {
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath


  mkdir -p "$THE_TMP/input/data"
  echo "hi" > "$THE_TMP/input/data/foo.png"
  
  echo "0,250x250::8-Gray,," > "$THE_TMP/bin/command.tasks"
  echo "1,,error," >> "$THE_TMP/bin/command.tasks"
  
  
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -inputPathRaw "$THE_TMP/input" -identifyCmd "$THE_TMP/bin/command" -lnCmd "$THE_TMP/bin/command" -CWS_outputdir $THE_TMP $WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"
  cat "$THE_TMP/$README_TXT"
  # Verify we got a workflow failed txt file
  [ -s "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  # Check output of workflow failed txt file
  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "${lines[0]}" == "simple.error.message=Error hardlinking data" ]
  [[ "${lines[1]}" == "detailed.error.message=Error running "* ]]

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
  [ "${lines[3]}" == "phase=Hardlinking data" ]

}


