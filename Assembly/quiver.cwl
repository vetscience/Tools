cwlVersion: v1.0
class: CommandLineTool
id: "quiver"
doc: "Polish the assembly using PacBio reads"
requirements:
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: quiver:latest
inputs:
  - id: dataDir
    type: Directory
    inputBinding:
      position: 1
      prefix: -d
  - id: assemblyDir
    type: string
    inputBinding:
      position: 2
      prefix: -a
  - id: assembly
    type: File
    inputBinding:
      position: 3
      prefix: -s
  - id: prefix
    type: string
    inputBinding:
      position: 4
      prefix: -p
  - id: fofn
    type: string
    inputBinding:
      position: 5
      prefix: -f
outputs:
  - id: assembled
    type:
      type: array
      items: [File, Directory]
    outputBinding:
      glob: "*"
#  - id: assembled
#    type:
#      type: array
#      items: [File, Directory]
#    outputBinding:
#      glob: "$inputs.workDir"
#  - id: assembly
#    type:
#      type: array
#      items: File
#    outputBinding:
#      #glob: "$(inputs.workDir)/$(inputs.prefix).contigs.fasta"
#      glob: "*/$(inputs.prefix).contigs.fasta"
  - id: quiverPolishedAssembly
    type: File
    format: edam:format_1929  # fasta
    outputBinding:
      glob: "$(inputs.prefix).contigs.quivered.fasta"
baseCommand: ["/root/Tools/smrtpipe.sh"]
arguments: []
#stdout: out
