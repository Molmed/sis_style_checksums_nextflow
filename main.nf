process CREATE_SIS_STYLE_CHECKSUMS {
    publishDir "${params.input_folder}/MD5/", mode: 'copy', overwrite: true

    input:
    path input_folder
    path include_file
    val ignore_cache

    output:
    path "checksums.md5"

    script:
    """
    create_sis_style_checksums.sh $input_folder $include_file $ignore_cache
    """
}

workflow {
    CREATE_SIS_STYLE_CHECKSUMS(
        params.input_folder,
        params.include_file,
        params.ignore_cache
    )
}
