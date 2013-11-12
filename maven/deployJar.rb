class JarDeployment
	def to_install_file(fileName, groupPrefix)
		generate_file(fileName) {|para| para.to_install_script(groupPrefix)}
	end

	def to_deploy_file(fileName, groupPrefix, url, repositoryId)
		generate_file(fileName) {|para| para.to_deploy_script(groupPrefix, url, repositoryId)}
	end

	private
	def deploy_parameters
		jarFileList = Dir.glob('./**/*/*.jar').uniq
		jarFileList.map do |jarFile|
			MavenParameter.new(File.expand_path(jarFile), 
				File.dirname(jarFile),
				File.basename(jarFile, ".jar"),
				"1.0-SNAPSHOT")
		end
	end

	def generate_file(fileName, &block)
		File.open(fileName, "w") do |file|
			deploy_parameters.each do |parameter|
				file.write(block.call(parameter))
				file.write("\n")
			end
		end
	end
end

class MavenParameter
	def initialize(filePath, groupId, artifactId, version)
		@filePath = filePath
		@groupId = groupId
		@artifactId = artifactId
		@version = version
	end

	def to_install_script(groupPrefix)
		"mvn install:install-file -Dfile=#{@file_path} -DgroupId=#{group_id(groupPrefix)} -DartifactId=#{@artifact_id} -Dversion=#{@version} -Dpackaging=jar"
	end

	def to_deploy_script(groupPrefix, url, repositoryId)
		"mvn deploy:deploy-file -Dfile=#{@file_path} -DgroupId=#{group_id(groupPrefix)} -DartifactId=#{@artifact_id} -Dversion=#{@version} -Dpackaging=jar -Durl=#{url} -DrepositoryId=#{repositoryId}"
	end

	private
	def group_id(groupPrefix)
		value = @groupId[2, @groupId.length]
		"#{groupPrefix}.#{value.gsub('/', '.')}"
	end
end

deployment = JarDeployment.new
deployment.to_install_file("install.txt", "com.agiledon")
deployment.to_deploy_file("deploy.txt", "com.agiledon", "http://localhost:8080/nexus-2.5/content/repositories/snapshots", "snapshots")