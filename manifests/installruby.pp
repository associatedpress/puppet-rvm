define rvm::installruby(
  $makedefault = false,
  $user,
  $rubyversion,
  $extraflags = undef,  
  $homeuser = "/home/$user",
){

  exec{ "rvm-requirements-$user-$rubyversion":
    path    => [ "/usr/bin", "/usr/sbin", "/bin", "/sbin" ],
    command => "$homeuser/.rvm/bin/rvm requirements",
    unless  => "$homeuser/.rvm/bin/rvm list | grep $rubyversion",
    require => [ User["$user"], Class["rvm::rubyreq"], Exec["installrvm-$user"] ],
    timeout => 0,
  }->

  exec{ "installrubies-$user-$rubyversion":
    path    => [ "/usr/bin", "/usr/sbin", "/bin", "/sbin" ],
    command => "/bin/bash --login -c 'HOME=$homeuser && rvm install $rubyversion $extraflags'",
    unless => "/bin/bash --login -c 'rvm list |grep $rubyversion'",
    user => "$user",
    environment => ["HOME=$homeuser"],
    require => [ Class["rvm::rubyreq"], Exec["installrvm-$user"] ],
    timeout => 0, # Hey, compiling can take a while! (by default in puppet 300 seconds)
    ;
  }

  #source "$HOME/.rvm/scripts/rvm"
  if $makedefault {
    exec{ "makedefaultruby-$user-$rubyversion":
      path    => [ "/usr/bin", "/usr/sbin", "/bin", "/sbin" ],
      #command => "$homeuser/.rvm/bin/rvm alias create default $rubyversion",
      command => "/bin/bash --login -c 'HOME=$homeuser && rvm alias create default $rubyversion'",
      unless => "/bin/bash --login -c 'HOME=$homeuser && rvm alias list |grep $rubyversion'",
      user => "$user",
      #path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      environment => ["HOME=$homeuser"],
      require => Class["rvm::rubyreq"],
      logoutput => true,
      ;
    }
  }

}
