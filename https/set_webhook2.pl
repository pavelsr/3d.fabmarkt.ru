use WWW::Telegram::BotAPI;
use Data::Dumper;

my $api = WWW::Telegram::BotAPI->new (
    token => '237382088:AAE8edrqW4h02Zfj8vSNv3Hyoix49_3Dx94',
    async => 0
);


warn Dumper $api->getMe;

warn Dumper $api->setWebhook({ url => 'https://3d.fablab61.ru'});
