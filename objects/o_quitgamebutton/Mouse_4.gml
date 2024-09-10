if instance_exists(o_progressask) { exit }
if instance_exists(o_quitask) { exit }

instance_create(-64,224,o_quitask)