cwlVersion: v1.0
class: CommandLineTool
id: "centrifuge"
doc: "Classify PacBio reads using the program centrifuge"
requirements:
  - class: InlineJavascriptRequirement
inputs:
  - id: database
    type: string
    inputBinding:
      position: 1
      prefix: -x
  - id: minHitLen
    type: int
    default: 22
    inputBinding:
      position: 2
      prefix: --min-hitlen
  - id: trimmedReads
    type: File
    inputBinding:
      position: 3
      prefix: -U
  - id: threads
    type: int
    inputBinding:
      position: 4
      prefix: -p
  - id : reportFile
    type: string
    default: report.txt
    inputBinding:
      position: 5
      prefix: --report-file
  - id : classificationFile
    type: string
    default: classification.txt
    inputBinding:
      position: 6
      prefix: -S
outputs:
  - id: report
    type: File
    outputBinding:
      glob: "$(inputs.reportFile)"
  - id: classification
    type: File
    outputBinding:
      glob: "$(inputs.classificationFile)"
baseCommand: ["centrifuge","-f"]
arguments: []
#stdout: out
hints:
  SoftwareRequirement:
    packages:
    - package: centrifuge
      version:
      - "1.0.3"
