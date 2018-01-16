cwlVersion: cwl:v1.0
class: Workflow
requirements:
#  - $import: pilon-typedef.yml
#  - $import: bowtie2-typedef.yml
  - $import: assembly-typedef.yml
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement
#  - class: InitialWorkDirRequirement
#    listing: [ $(indexBamFile.bamIndexFile), $(sortMappedReads.sortedBamFile) ]

inputs:
  dataDir: Directory
  assemblyDir: string
  currentDir: string
  prefix: string
  fofn: string
  results: string
  genomeSize: string
  readsPe1:
    type: File[]
  readsPe2:
    type: File[]
  phredsPe:
    type: assembly-typedef.yml#phred[]
  slidingWindow: assembly-typedef.yml#slidingWindow
  illuminaClip: assembly-typedef.yml#illuminaClipping?
  leading: int
  trailing: int
  minlen: int
  threads: int
  phred: assembly-typedef.yml#phred
  orientation: assembly-typedef.yml#orientation
  maxFragmentLens: int[]
  #quiverPolishedAssembly:
  #  type: File
  polishedAssembly: string
  diploidOrganism: string
  fix: string
  modifications: string
  database: string
  taxons:
    type: int[]

outputs:
  correctedReads:
    type: File
    outputSource: correct/correctedReads
  trimmedReads:
    type: File
    outputSource: trim/trimmedReads
  quiverAssembly:
    type: File
    outputSource: quiver/quiverPolishedAssembly
  finalAssembly:
    type: File
    outputSource: pilon/pilonPolishedAssembly
  trimmedReadFiles1:
    type: File[]
    outputSource: cleanIlluminaReads/trimmedPe1
  trimmedReadFiles2:
    type: File[]
    outputSource: cleanIlluminaReads/trimmedPe2
  sortedBamIndexFileOut:
    type: File[]
    outputSource: indexBamFile/indexedBamFile
  deconReport:
    type: File
    outputSource: classifyReads/report
  deconClassification:
    type: File
    outputSource: classifyReads/classification
  decontaminatedReads:
    type: File
    outputSource: decontaminate/deconReads
  contaminatedReads:
    type: File
    outputSource: decontaminate/conReads

steps:
  cleanIlluminaReads:
    run: trimmomaticpe.cwl
    in:
      currentDir: currentDir
      phred: phredsPe
      threads: threads
      reads1: readsPe1
      reads2: readsPe2
      slidingWindow: slidingWindow
      illuminaClip: illuminaClip
      leading: leading
      trailing: trailing
      minlen: minlen
    out: [trimmedPe1, trimmedPe2, trimmedUnpe1, trimmedUnpe2, trimLogFile]
    scatter: [reads1, reads2, phred]
    scatterMethod: dotproduct

  hdf5check:
    run: hdf5check.cwl
    in:
      directory: dataDir
      results: results
    out: [pbFastqReads]

  correct:
    run: canuCorrect.cwl
    in:
      prefix: prefix
      assemblyDir: assemblyDir
      genomeSize: genomeSize
      pacbio-raw: hdf5check/pbFastqReads
    out: [correctedReads]

  trim:
    run: canuTrim.cwl
    in:
      prefix: prefix
      assemblyDir: assemblyDir
      genomeSize: genomeSize
      pacbio-corrected: correct/correctedReads
    out: [trimmedReads]

  renameReads:
    run: renameReads.cwl
    in:
      trimmedReads: trim/trimmedReads
    out: [renamedReads]

  classifyReads:
    run: centrifuge.cwl
    in:
      database: database
      trimmedReads: renameReads/renamedReads
      threads: threads
    out: [report, classification]

  decontaminate:
    run: decon.cwl
    in:
      trimmedReads: renameReads/renamedReads
      taxons: taxons
      classificationFile: classifyReads/classification
    out: [deconReads, conReads]

  assemble:
    run: canuAssemble.cwl
    in:
      prefix: prefix
      assemblyDir: assemblyDir
      genomeSize: genomeSize
      pacbio-corrected: decontaminate/deconReads
    out: [assembly]

  quiver:
    run: quiver.cwl
    in:
      dataDir: dataDir
      assemblyDir: assemblyDir
      assembly: assemble/assembly
      prefix: prefix
      fofn: fofn
    out: [quiverPolishedAssembly]

  indexReference:
    run: bowtie2-build.cwl
    in:
      reference: quiver/quiverPolishedAssembly
      #reference: quiverPolishedAssembly
    out: [idxFile]

  mapIlluminaReads:
    run: bowtie2.cwl
    in:
      phred: phred
      orientation: orientation
      maxFragmentLen: maxFragmentLens
      threads: threads
      reference: indexReference/idxFile
      reads1: cleanIlluminaReads/trimmedPe1
      reads2: cleanIlluminaReads/trimmedPe2
    out: [samFile]
    scatter: [reads1, reads2, maxFragmentLen]
    scatterMethod: dotproduct

  sortMappedReads:
    run: samsort.cwl
    in:
      threads: threads
      #outputBamFile: sortedBamFile
      inputSamFile: mapIlluminaReads/samFile
    out: [sortedBamFile]
    scatter: inputSamFile

  indexBamFile:
    run: samindex.cwl
    in:
      inputBamFile: sortMappedReads/sortedBamFile
    out: [indexedBamFile]
    scatter: inputBamFile

  pilon:
    run: pilon.cwl
    in:
      currentDir: currentDir
      bamPe: indexBamFile/indexedBamFile
      reference: quiver/quiverPolishedAssembly
      #reference: quiverPolishedAssembly
      output: polishedAssembly
      diploidOrganism: diploidOrganism
      fix: fix
      modifications: modifications
    out: [pilonPolishedAssembly, pilonPolishedAssemblyChanges]

