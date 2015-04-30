	{assign var=in_hive value=$me_user_obj->UserInHive($thisuser)}
	{assign var=in_honeycomb value=$me_user_obj->UserInHoneycomb($thisuser)}
	{assign var=is_seller value=$me_user_obj->IsUserSeller($thisuser)}
	
	<form method="POST" onSubmit="return really_submit(this.elements['do_submit'].value);"><td align="left" id="userdisplay" valign="middle" nowrap><a href="/users/{$thisuser}/">{$thisuser}</a>
	<input type="hidden" name="do_submit" value="0">
	{if $me_user != $thisuser}
	
    {if $in_hive == 0}
	  <input type="image" align="middle" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/{$me_user}/hive/{$thisuser}/';" src="/thematics/hive-add.gif" alt="Add {$thisuser} to My Hive." title="Add {$thisuser} to My Hive.">
	{else}
      <input type="image" align="middle" src="/thematics/hive-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/{$me_user}/hive/{$thisuser}/');" alt="Remove {$thisuser} from My Hive." title="Remove {$thisuser} from My Hive.">
	{/if}

    {if $is_seller}
    {if $in_honeycomb == 0}
	  <input type="image" align="center" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/{$me_user}/honeycomb/{$thisuser}/';" src="/thematics/honeycomb-add.gif" alt="Add {$thisuser} to My Honeycomb." title="Add {$thisuser} to My Honeycomb.">
	{else}
	  {if $me_user_obj->CheckMyReco($thisuser) > 0}
	    <input type="image" align="center" src="/thematics/recommend-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/{$me_user}/recommendations/{$thisuser}/');" title="Rescind your recommendation of {$thisuser}." alt="Rescind your recommendation of {$thisuser}.">
	  {else}
	    <input type="image" align="center" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/{$thisuser}/recommendations/';" src="/thematics/recommend-add.gif" alt="Recommend {$thisuser} as a quality Seller." title="Recommend {$thisuser} as a quality Seller.">
	  {/if}
      <input type="image" align="center" src="/thematics/honeycomb-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/{$me_user}/honeycomb/{$thisuser}/');" alt="Remove {$thisuser} from My Honeycomb." title="Remove {$thisuser} from My Honeycomb.">
	{/if}
	{/if}
	
	<input type="image" align="center" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/{$me_user}/blacklist/{$thisuser}/';" src="/thematics/blacklist-add.gif" alt="Blacklist {$thisuser}." title="Blacklist {$thisuser}.">

	{else}
      <input type="image" align="middle" src="/thematics/{$t_list}-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/{$user}/{$t_list}/{$thisuser}/');" alt="Remove Me from {$user}'s {$list_label}." title="Remove Me from {$user}'s {$list_label}.">
	{/if}
	</td></form>
	
	