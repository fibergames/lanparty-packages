class Nginx < FPM::Cookery::Recipe
  description 'high-performance web server built with replace-filter module'

  name      'nginx'
  version   '1.11.6'
  revision  'no-etag~git'
  provides  'nginx'
  section   'lanparty'

  homepage 'https://nginx.org'

  build_depends \
    'libpcre3-dev',
    'zlib1g-dev',
    'libssl-dev'

  depends \
    'libsregex',
    'nginx-common',
    'libpcre3',
    'zlib1g',
    'libssl1.0.0'

  replaces  'nginx-full', 'openresty'
  conflicts 'nginx-full', 'openresty'

  exclude 'etc'

  source 'http://git.incline.eu/timo/nginx.git', :with => 'git', :branch => 'no-etag'

  chain_package true
  chain_recipes 'sregex'

  def build
    sh 'git clone https://github.com/openresty/replace-filter-nginx-module.git'

    sh 'cp auto/configure .'

    configure \
      '--with-http_ssl_module',
      '--with-http_realip_module',
      '--with-http_addition_module',
      '--with-http_sub_module',
      '--with-http_dav_module',
      '--with-http_flv_module',
      '--with-http_mp4_module',
      '--with-http_gunzip_module',
      '--with-http_gzip_static_module',
      '--with-http_random_index_module',
      '--with-http_secure_link_module',
      '--with-http_stub_status_module',
      '--with-http_auth_request_module',
      '--with-mail',
      '--with-mail_ssl_module',
      '--with-file-aio',
      '--with-ipv6',
      '--with-threads',
      '--with-stream',
      '--with-stream_ssl_module',
      '--with-http_slice_module',
      '--with-http_v2_module',

      '--add-module=replace-filter-nginx-module',

      :sbin_path => '/usr/sbin/nginx',
      :conf_path => '/etc/nginx/nginx.conf',
      :lock_path => '/var/lock/nginx.lock',
      :pid_path => '/run/nginx.pid',
      :http_log_path => '/var/log/nginx/access.log',
      :error_log_path => '/var/log/nginx/error.log',
      :http_client_body_temp_path => '/var/lib/nginx/body',
      :http_fastcgi_temp_path => '/var/lib/nginx/fastcgi',
      :http_proxy_temp_path => '/var/lib/nginx/proxy',
      :http_scgi_temp_path => '/var/lib/nginx/scgi',
      :http_uwsgi_temp_path => '/var/lib/nginx/uwsgi'

    make '-j8'
  end

  def install
    make :install, 'DESTDIR' => destdir

    # Holds cache files etc., not created by make
    var('lib/nginx').mkpath

  end

end
