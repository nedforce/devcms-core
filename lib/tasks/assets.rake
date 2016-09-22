namespace :assets do
  logger = Logger.new($stderr)

  # Generates non-digested files, see config.non_digest_assets setting.
  # https://bibwild.wordpress.com/2014/10/02/non-digested-asset-names-in-rails-4-your-options/
  task :create_non_digest_assets => :"assets:environment"  do
    manifest_path = Dir.glob(File.join(Rails.root, 'public/assets/.sprockets-manifest-*.json')).first
    manifest_data = JSON.load(File.new(manifest_path))

    manifest_data["assets"].each do |logical_path, digested_path|
      logical_pathname = Pathname.new logical_path

      if Rails.application.config.assets.non_digest_assets.any? {|testpath| logical_pathname.fnmatch?(testpath, File::FNM_PATHNAME) }
        full_digested_path    = File.join(Rails.root, 'public/assets', digested_path)
        full_nondigested_path = File.join(Rails.root, 'public/assets', logical_path)

        logger.info "Copying #{full_digested_path} to non-digested asset path #{full_nondigested_path}"

        # Use FileUtils.copy_file with true third argument to copy
        # file attributes (eg mtime) too, as opposed to FileUtils.cp
        # Making symlnks with FileUtils.ln_s would be another option, not
        # sure if it would have unexpected issues.
        FileUtils.copy_file full_digested_path, full_nondigested_path, true
      end
    end
  end
end

Rake::Task['assets:precompile'].enhance do
  Rake::Task['assets:create_non_digest_assets'].invoke
end
