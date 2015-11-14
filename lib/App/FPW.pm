package App::FPW;
use Dancer ':syntax';

=head1 NAME

App::FPW - oijaisdjoijqwe

=head1 SYNOPSIS

  # Beispielverwendung

=cut

our $VERSION = '0.1';

use JSON qw<encode_json decode_json>;

sub load_config {
    my ($filename) = @_;
    open my $fh, '<', $filename
        or die "No config file '$filename': $!.";
    binmode $fh;
    local $/;
    my $content = <$fh>;
    my $config = decode_json( $content );
    return $config
};

sub save_config {
    my ($filename, $config) = @_;
    my $content = encode_json($config);
    open my $fh, '>', $filename
        or die "No config file: $!";
    binmode $fh;
    local $/;
    print $fh $content;
};

get '/' => sub {
    template 'index', {
        user_id => session('user_id')
    };
;
};

get '/login' => sub {
    template 'login', {
        user_id => session('user_id')
    };
};

get '/logout' => sub {
    session('user_id', '');
    return redirect '/';
};

my %credentials = (
   'x' => 'y',
);

post '/login' => sub {
    my $user = params->{'username'};
    my $pass = params->{'password'};
    
    my $message;
    if( $credentials{ $user } eq $pass ) {
       $message = "Willkommen!";
       session( "user_id" => $user );
    } else {
       $message = "Nicht mit diesen Schuhen!";
    };

    template 'login', {
        message => $message,
    };
};

post '/upload' => sub {
    # Dancer::Upload
};

get '/view/:file' => sub {
    # /view/foo.txt
    
    warn params->{file};
};

sub config_file {
    return
        dirname($0) . '/../db/verteiler.json'
};

sub logged_in {
    return session->{user_id}
};

hook before => sub {
    my( $route ) = @_;
    if(     not logged_in()
        and $route->pattern ne '/login'
        and $route->pattern ne '/'
      ) {
            warn sprintf "Not logged in for request to %s, redirecting to /login",
              $route->pattern;
            return redirect '/login'
        };
};

get '/mailtext' => sub {

    my $config = load_config(config_file());
    
    template 'mailtext', {
        user_id => session('user_id'),
        mailtext => $config->{mailtext},
        subject => $config->{subject},
        # zeitstempel mitgeben
    };
};

post '/mailtext' => sub {
    my $config = load_config(config_file());
    
    # Zeitstempel der letzten Änderung prüfen
    # überschreiben
    $config->{mailtext} = params->{mailtext};
    $config->{subject} = params->{subject};
    
    save_config(config_file(), $config );
    redirect '/mailtext';
};

true;

__END__

=head1 LICENSE

=cut

Idee: Monatliches Mail Verschicken
Mailtext etwas anpassbar
List von Empfängern
Zeitpunkt des Versendens wählbar

get /empfaenger
    - zeigt Mailadressen an

post /empfaenger/add
    - haengt einen neuen Empfaenger an die Liste an
    Form Parameter: mailadresse
    - Duplikate sind nicht erlaubt
    
post /empfaenger/delete
    - loescht den Empfaenger im Form Parameter "mailadresse"

get /mailtext
    - zeigt das Mailformular an mit Platzhaltern

post /mailtext
    - setzt das Mailformular neu
    Parameter:
        subject
        mailtext

get /schedule
    - liefert das Versanddatum

post /schedule
    - setzt das Versanddatum
    
Features für v2:
    Redirect nach login zur ursprünglich angefragten Seite