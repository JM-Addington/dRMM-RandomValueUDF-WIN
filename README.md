# Overview #

Ever wish that Datto RMM made it easier to rollout changes in multiple stages? This component will allow you to set a UDF to a random number
between 0 and a maximum of your choosing. Combined with a filter (UDF contains {0, 1, 2, ... max_number}) you can now set policies and jobs
to rollout at specific stages.

# Usage #

Run the component, choosing the UDF number you want to set and the maximum number it should return.

# Building #

Download or fork, run repackage.bat and upload aem-component.cpt to dRMM. You can also download the aem-component.cpt straight from this repository and install in your dRMM instance.