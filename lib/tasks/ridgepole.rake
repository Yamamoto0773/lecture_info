namespace :ridgepole do
  desc 'apply schema contents to database'
  task apply: :environment do
    bundle exec "ridgepole -c config/database.for.heroku.ridgepole.yml -E production -f db/Schemafile --apply"
  end
end
