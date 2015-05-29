#!/usr/bin/env bats

load test_helper

#
# Test 
#
@test "png files not same dimensions" {
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath


  mkdir -p "$THE_TMP/input/data"
  echo "hi" > "$THE_TMP/input/data/foo.png"
  echo "hi" > "$THE_TMP/input/data/foo2.png"
  echo "hi" > "$THE_TMP/input/data/foo3.png"
  

  echo "0,500x500::8-Gray,," > "$THE_TMP/bin/command.tasks"
  echo "0,500x500::8-Gray,," >> "$THE_TMP/bin/command.tasks"
  echo "0,500x1500::8-Gray,," >> "$THE_TMP/bin/command.tasks"
  
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -inputPathRaw "$THE_TMP/input" -identifyCmd "$THE_TMP/bin/command" -CWS_outputdir $THE_TMP $WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"
  cat "$THE_TMP/$README_TXT"

  # Verify we got a workflow failed txt file
  [  -e "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "${lines[0]}" == "simple.error.message=No valid images found" ]
  [[ "${lines[1]}" == "detailed.error.message=Error Dimension of image $THE_TMP/"*" 500x1500 does not match 500x500"* ]]

  
}


