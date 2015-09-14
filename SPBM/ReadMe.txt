# Note for Contributors
I have compiled all of the functions into a module file, SolidFire-SPBM.psm1.  
Please provide updates and pull requests to the individual functions.  
I have a function that will roll all of the functions together into the module and incorporate updates.  I will do so when pull requests are accepted.

# Capabilities
You can use these functions to do things such as:
- Create Tags based on SolidFire Volume characteristics
- Set Volume Attributes easily.
- Assign Tags and Policies to datastores
- Create QoS profile based on an existing policy
- Create Policy name based on QoS and Attributes of a volume
- Create tag, category, assign datastore, and create new policy based on an existing volume/datastore with one function

# Why is this useful?
In short this allows organizations leveraging SolidFire in a VMware environment to easily begin utilizing Storage Policy Based Management (SPBM) in order to properly classify their datastores for consumption. Assigning datastores (and the underlying SF volumes) to policies means that consumers can understand the characteristics of the storage their applications are running atop.  Administrators can ensure that policies are adhered to and do so dynamically. Automation can be built with these functions that will allow an administrator to alter the characteristics of a volume and assign it to an appropriate policy when necessary. This provides the ability to change the performance characteristics of a datastore, and ensure proper policy alignment, without the need of storage vmotion. Additionally, this management framework is the model that is used for vSphere Virtual Volumes.

You can learn more about this and more in future blog posts at http://developer.solidfire.com/blogs.

# Note on Set-SFVolumeAttribute
Natively Set-SFVolume replaces attribute values with the hash table provided when called.  The Set-SFVolumeAttribute is designed to add some extra logic that will be made available in a later build.  If the key exists it will simply update the value.  If it does not exist it will simply add the key:value pair to the attributes of the volume.  The function collects any existing attributes so that when the call is made those values are not replaced.

# Version Note
These functions are built using SolidFire Tools for PowerShell 1.0RC.  
As such some parameter and property names may have changed slightly since the beta release.
These were necessary improvements to improve ease of use and consistency.
If you are running the beta build and would like to take advantage of these functions please email us at powershell@solidfire.com
