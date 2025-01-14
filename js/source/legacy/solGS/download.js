/**
 * solGS prediction raw, model input downloads
 * Isaak Y Tecle <iyt2@cornell.edu>
 *
 */

var solGS = solGS || function solGS() {};

solGS.download = {
  getTrainingPopRawDataFiles: function () {
    var args = solGS.getTrainingPopArgs();
    args = JSON.stringify(args);

    var popDataReq = jQuery.ajax({
      type: "POST",
      dataType: "json",
      data: {
        arguments: args,
      },
      url: "/solgs/download/training/pop/data",
    });

    return popDataReq;
  },

  getSelectionPopRawDataFiles: function () {
    var args = solGS.getSelectionPopArgs();
    args = JSON.stringify(args);

    var popDataReq = jQuery.ajax({
      type: "POST",
      dataType: "json",
      data: {
        arguments: args,
      },
      url: "/solgs/download/selection/pop/data",
    });

    return popDataReq;
  },


  getTraitsAcronymFile: function () {
    var args = solGS.getTrainingPopArgs();
    args = JSON.stringify(args);

    var popDataReq = jQuery.ajax({
      type: "POST",
      dataType: "json",
      data: {
        arguments: args,
      },
      url: "/solgs/download/traits/acronym",
    });

    return popDataReq;
  },

  createTrainingPopDownloadLinks: function (res) {
    var genoFile = res.training_pop_raw_geno_file;
    var phenoFile = res.training_pop_raw_pheno_file;

    var genoFileName = genoFile.split("/").pop();
    var genoFileLink =
      '<a href="' + genoFile + '" download=' + genoFileName + '">' + "Genotype data" + "</a>";

    var phenoFileName = phenoFile.split("/").pop();
    var phenoFileLink =
      '<a href="' + phenoFile + '" download=' + phenoFileName + '">' + "Phenotype data" + "</a>";

    var traitsAcronymLink = this.createTraitsAcronymLinks(res);

    var downloadLinks =
      " <strong>Download training population</strong>: " +
      genoFileLink +
      " | " +
      phenoFileLink + " | " + traitsAcronymLink;

    jQuery("#training_pop_download").prepend(
      '<p style="margin-top: 20px">' + downloadLinks + "</p>"
    );
  },


  createTraitsAcronymLinks: function (res) {
    var acronymFile = res.traits_acronym_file;

    var acronymFileName = acronymFile.split("/").pop();
    var acronymFileLink =
      '<a href="' + acronymFile + '" download=' + acronymFileName + '">' + "Traits acronyms" + "</a>";

    return acronymFileLink;

  },

  createSelectionPopDownloadLinks: function (res) {
    var genoFile = res.selection_pop_filtered_geno_file;

    var genoFileName = genoFile.split("/").pop();
    var genoFileLink =
      '<a href="' + genoFile + '" download=' + genoFileName + '">' + "Genotype data" + "</a>";

    var downloadLinks =
      " <strong>Download selection population</strong>: " +
      genoFileLink;

    jQuery("#selection_pop_download").prepend(
      '<p style="margin-top: 20px">' + downloadLinks + "</p>"
    );
  },

  getModelInputDataFiles: function () {
    var args = solGS.getModelArgs();
    args = JSON.stringify(args);

    var modelInputReq = jQuery.ajax({
      type: "POST",
      dataType: "json",
      data: {
        arguments: args,
      },
      url: "/solgs/download/model/input/data",
    });

    return modelInputReq;
  },

  createModelInputDownloadLinks: function (res) {
    var genoFile = res.model_geno_data_file;
    var phenoFile = res.model_pheno_data_file;

    console.log("geno file: " + genoFile);
    console.log("pheno file: " + phenoFile);

    var genoFileName = genoFile.split("/").pop();
    var genoFileLink =
      '<a href="' + genoFile + '" download=' + genoFileName + '">' + "Genotype data" + "</a>";

    var phenoFileName = phenoFile.split("/").pop();
    var phenoFileLink =
      '<a href="' + phenoFile + '" download=' + phenoFileName + '">' + "Phenotype data" + "</a>";

    var downloadLinks =
      " <strong>Download model</strong>: " + genoFileLink + " | " + phenoFileLink;

    jQuery("#model_input_data_download").prepend(
      '<p style="margin-top: 20px">' + downloadLinks + "</p>"
    );
  },

  getValidationFile: function () {
    var args = solGS.getModelArgs();
    args = JSON.stringify(args);

    var valDataReq = jQuery.ajax({
      type: "POST",
      dataType: "json",
      data: {
        arguments: args,
      },
      url: "/solgs/download/model/validation",
    });

    return valDataReq;
  },

  createValidationDownloadLink: function (res) {
    var valFileName = res.validation_file.split("/").pop();
    var valFileLink =
      '<a href="' +
      res.validation_file +
      '" download=' +
      valFileName +
      '">' +
      "Download model accuracy" +
      "</a>";

    jQuery("#validation_download").prepend('<p style="margin-top: 20px">' + valFileLink + "</p>");
  },

  getMarkerEffectsFile: function () {
    var args = solGS.getModelArgs();
    args = JSON.stringify(args);

    var markerEffectsReq = jQuery.ajax({
      type: "POST",
      dataType: "json",
      data: {
        arguments: args,
      },
      url: "/solgs/download/model/marker/effects",
    });

    return markerEffectsReq;
  },

  createMarkerEffectsDownloadLink: function (res) {
    var effectsFileName = res.marker_effects_file.split("/").pop();
    var effectsFileLink =
      '<a href="' +
      res.marker_effects_file +
      '" download=' +
      effectsFileName +
      '">' +
      "Download marker effects" +
      "</a>";

    jQuery("#marker_effects_download").prepend(
      '<p style="margin-top: 20px">' + effectsFileLink + "</p>"
    );
  },
};

jQuery(document).ready(function () {

  var downloadMsgDiv = "#download_message";
  solGS.checkPageType().done(function (res) {
    if (res.page_type.match(/training population/)) {
      solGS.download.getTrainingPopRawDataFiles().done(function (res) {
        solGS.download.createTrainingPopDownloadLinks(res);
      });

      solGS.download.getTrainingPopRawDataFiles().fail(function (res) {
        var errorMsg = "Error occured getting training pop raw data files.";
        solGS.showMessage(downloadMsgDiv, errorMsg)
      });

      solGS.download.getTrainingPopRawDataFiles().fail(function (res) {
        var errorMsg = "Error occured getting training pop raw data files.";
        solGS.showMessage(downloadMsgDiv, errorMsg)
      });


    } else if (res.page_type.match(/training model/)) {
      solGS.download.getModelInputDataFiles().done(function (res) {
        solGS.download.createModelInputDownloadLinks(res);
      });

      solGS.download.getModelInputDataFiles().fail(function (res) {
        var errorMsg = "Error occured getting model input data files.";
        solGS.showMessage(downloadMsgDiv, errorMsg)
      });

      solGS.download.getValidationFile().done(function (res) {
        solGS.download.createValidationDownloadLink(res);
      });

      solGS.download.getValidationFile().fail(function (res) {
        var errorMsg = "Error occured getting model validation file.";
        solGS.showMessage("#validation_download_message", errorMsg);
      });

      solGS.download.getMarkerEffectsFile().done(function (res) {
        solGS.download.createMarkerEffectsDownloadLink(res);
      });

      solGS.download.getMarkerEffectsFile().fail(function (res) {
        var errorMsg = "Error occured getting marker effects file.";
        solGS.showMessage("#marker_effects_download_message", errorMsg);

      });
    } else if (res.page_type.match(/selection population/)) {
        solGS.download.getSelectionPopRawDataFiles().done(function (res) {
          solGS.download.createSelectionPopDownloadLinks(res);
        });

        solGS.download.getSelectionPopRawDataFiles().fail(function (res) {
          var errorMsg = "Error occured getting selection population genotype data files.";
          solGS.showMessage(downloadMsgDiv, errorMsg);
        });
      }
  });

  solGS.checkPageType().fail(function (res) {
    var errorMsg = "Error occured checking for page type.";
    solGS.showMessage(downloadMsgDiv, errorMsg)

  });
});
