name "farcryless"
description "Setup FarCry LESS Plugin Test Environment"
run_list(
	"recipe[farcryless::timezone]",
	"recipe[git]",
	"recipe[farcryless::farcry]",
	"recipe[farcryless::mysql]",
	"recipe[farcryless::db]",
	"recipe[apache2]",
	"recipe[farcryless::sites]",
	"recipe[farcryless::lucee]"
)