package MyApp::Model::Menu;

use base qw/Catalyst::Model::WWW::MenuGrinder/;

__PACKAGE__->config(
  menu_config => {
    plugins => [
      'XMLLoader',
      'FileReloader',
      'DefaultTarget',
      'Variables',
      'ActivePath',
      'NullOutput',
    ],
    filename => MyApp->path_to('root', 'menu.xml'),
  },
);

1;

