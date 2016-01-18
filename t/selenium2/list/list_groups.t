
use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::WWW::WebDriver;

my $d = SGN::Test::WWW::WebDriver->new();

$d->login_as("submitter");

$d->get_ok("/", "get root url test");

my $out = $d->find_element_ok("lists_link", "name", "find lists_link")->click();

$d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("make_public_selected_list_group", "id", "make public selected list group")->click();

sleep(1);

$d->accept_alert_ok();

sleep(1);

$d->find_element_ok("view_public_lists_button", "id", "view public lists")->click();

sleep(1);

$d->find_element_ok("view_public_list_johndoe_1_private", "id", "check view public lists");

sleep(1);

$d->find_element_ok("close_public_list_item_dialog", "id", "close public lists")->click();

sleep(1);

$d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("make_private_selected_list_group", "id", "make private selected list group")->click();

sleep(1);

$d->accept_alert_ok();

sleep(1);

$d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("new_combined_list_name", "id", "combine selected list group")->send_keys("combined_list");

$d->find_element_ok("combine_selected_list_group", "id", "combine selected list group")->click();

sleep(1);

$d->accept_alert_ok();

sleep(1);

$d->find_element_ok("view_list_combined_list", "id", "check view combined list");

sleep(1);

$d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list")->click();

sleep(1);

$d->find_element_ok("delete_selected_list_group", "id", "delete selected list group")->click();

sleep(1);

$d->accept_alert_ok();

sleep(1);


$d->find_element_ok("close_list_dialog_button", "id", "find close dialog button")->click();

$d->logout_ok();

done_testing();

$d->driver->close();