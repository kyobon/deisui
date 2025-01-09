#ベースイメージとしてrubyを指定
FROM ruby:3.3.3

#実行環境指定
ENV RAILS_ENV=ENV['RAILS_ENV']

#作業ディレクトリの指定
WORKDIR /app

#アプリケーションコードがローカルのalcoholの配下にあるため、コンテナのapp配下にコピー
COPY alcohol /app

#コンテナ内にコピーしたGemfileを用いてbundel install
RUN bundle config --local set path 'vendor/bundle' \
  && bundle install

#アセットのプリコンパイル
RUN rails assets:precompile

# コンテナ起動時に実行されるスクリプトを追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 80

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "80"]