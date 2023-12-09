function ReadMe() {
	/*

# Dissonance

	**Dissonance is no way created by, endorsed by, or affiliated with Discord.**
	Dissonance is built on [discord-rpc](https://github.com/discordapp/discord-rpc)

## Welcome to Dissonance

	Initial Steps:

	* Setup your [app with discord](https://discordapp.com/developers/applications/me)
	* Familiarized yourself with the Rich Presence FAQ / How-To: https://discordapp.com/developers/docs/rich-presence/how-to

	Once you've done this, you're ready to use Dissonance!

### Creating Dissonance

	Before you can call **Any** `rousr_dissonance_` functions: 

	* Call `rousr_dissonance_create(<your-app-id>)` to create the Dissonance object and initialize the Discord RPC.

	Next, setup your handlers.. none of them are actually required, but if you're going to have join / spectate functionality, or 
	want to catch when the RPC is ready / log errors, they are available:

	* rousr_dissonance_handler_on_ready(_script_index, [_user_data])
	* rousr_dissonance_handler_on_disconnected(_script_index, [_user_data])
	* rousr_dissonance_handler_on_error(_script_index, [_user_data])
	* rousr_dissonance_handler_on_join(_script_index, [_user_data])
	* rousr_dissonance_handler_on_spectate(_script_index, [_user_data])
	* rousr_dissonance_handler_on_join_request(_script_index, [_user_data])

	**Note:** When receiving a join request, prompt the player with options to accept or reject the invite, sending the reply with the following:  
	* rousr_dissonance_respond_to_join(_user_id, _reply) (_reply is a `EDissonanceJoinReply` value)

### Set Rich Presence Fields

	The following functions set the various [fields](https://discordapp.com/developers/docs/rich-presence/how-to#updating-presence-update-presence-payload-fields):

	* rousr_dissonance_set_details(_details)
	* rousr_dissonance_set_large_image(_image_key, [_image_text])
	* rousr_dissonance_set_small_image(_image_key, [_image_text])
	* rousr_dissonance_set_timestamps(_secondsFromNowStart, _secondsFromNowEnd)
	* rousr_dissonance_set_state(_state)
	* rousr_dissonance_set_party(_party_size, _party_max, [_party_id])
	* rousr_dissonance_set_join_secret(_secret)
	* rousr_dissonance_set_spectate_secret(_secret)
	* rousr_dissonance_set_match_secrete(_match_secret, _is_instance)

#### Note on Example Assets

	If you want to follow the Example exactly, I've included two 1024x1024 png files in the Included Files section of the resource tree. 
	Upload these both to the "Rich Presence Assets" section of your dashboard:

	* **dissonance_small.png**
	  * Name: `dissonance` 
	  * Type: `Small`
	* **dissonance_large.png**
	  * Name: `dissonance_large` 
	  * Type: `Large`

	*/


}
