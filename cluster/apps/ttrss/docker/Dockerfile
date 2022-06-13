# See https://github.com/Skyr/docker-ttrss
# A lot of ttrss docker images integrate scripts that update ttrss when the container restarts.
# I'd rather have an immutable image, as created by skyr0
FROM skyr0/ttrss:26

ENV ttrss_rev ceb8179ccc692430d52deb8e154e07a78569b412

# I don't want to have the plugins and themes in a docker volume. Remove the link.
RUN cd /var/www/ttrss && rm -rf themes.local plugins.local && \
    mkdir -p themes.local plugins.local

# Add some plugins
RUN cd /var/www/ttrss/plugins.local && git clone https://github.com/feediron/ttrss_plugin-feediron.git feediron && \
    git clone https://github.com/HenryQW/mercury_fulltext.git && \
    git clone https://github.com/DigitalDJ/tinytinyrss-fever-plugin fever
