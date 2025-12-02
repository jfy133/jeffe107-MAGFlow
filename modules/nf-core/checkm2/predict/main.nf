process CHECKM2 {
	tag "${sample}"
	label 'process_medium'

	conda "bioconda::checkm2=1.0.1 conda-forge::python=3.7.12"
	container "${params.use_singularity
		? 'https://depot.galaxyproject.org/singularity/checkm2:1.0.1--pyh7cba7a3_0'
		: 'biocontainers/checkm2:1.0.1--pyh7cba7a3_0'}"
	containerOptions "${params.directory_to_bind == null ? '' : "--bind ${params.directory_to_bind}"}"

	input:
	tuple val(sample), path(files), val(change_dot_for_underscore)
	path checkm2_db
	path gtdbtk2_db

	output:
	path "checkm2", emit: checkm2
	path "versions.yml", emit: versions

	script:
	def args = task.ext.args ?: ''
	"""
	EXTENSION=\$(echo ".\$(ls ${files}/* | head -n 1 | rev | cut -d. -f1 | rev)")
	checkm2 predict \
        --threads ${task.cpus} \
        --input ${files} -x \$EXTENSION \
        --output-directory checkm2 \
		--database_path ${checkm2_db} \
		${args}

	cat <<-END_VERSIONS > versions.yml
		checkm2: \$(checkm2 --version)
	END_VERSIONS
	"""
}
