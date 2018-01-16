cwlVersion: cwl:v1.0
class: Workflow
requirements:
  - class: InlineJavascriptRequirement

inputs:
  directory: Directory
  results: string
  prefix: string
  workDir: Directory
  genomeSize: string

outputs:
  assemblyData:
    type:
      type: array
      items: [File, Directory]
    outputSource: assemble/assembly

steps:
  hdf5check:
    run: hdf5check.cwl
    in:
      directory: directory
      results: results
    out: [fastaAndFastqFiles]

  assemble:
    run: canu.cwl
    in:
      prefix: prefix
      workDir: workDir
      genomeSize: genomeSize
      pacbio-raw: hdf5check/fastaAndFastqFiles
    out: [assembly]
