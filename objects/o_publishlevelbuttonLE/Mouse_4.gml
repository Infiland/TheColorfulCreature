var _modal = instance_find(o_publishlevelLE, 0);
if (!instance_exists(_modal) || !_modal.visible || !timing_ui_publish_eligible()) exit;
if (!scr_saveleveleditor()) exit;
instance_destroy(o_publishlevelLE)
instance_destroy(o_readworkshoprulesLE)
instance_destroy(o_publishlevelbuttonLE)
instance_create(x,y,o_publishinghappenshere)
