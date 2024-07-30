//***********************************************************************
//***********************************************************************
// Copyright Blue Book Services 2015-2018
//
// The use, disclosure, reproduction, modification, transfer, or  
// transmittal of  this work for any purpose in any form or by any 
// means without the written  permission of Travant Solutions is 
// strictly prohibited.
//
// Confidential, Unpublished Property of Travant Solutions, Inc.
// Use and distribution limited solely to authorized personnel.
//
// All Rights Reserved.
//
// Notice:  This file was created by Travant Solutions, Inc.  Contact
// by e-mail at info@travant.com
//
// Filename: map.js (Spanish Version)
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************
var geocoder = null;
var map = null;
var bounds = null;
var infowindow = null;
var infoWindows = [];

var companies = null;
var directionsService;
var directionsDisplay;

var pause = 1000;
var geoCodeCount = 0;

var fromAddress = "<p><strong>Instrucciones para llegar aquí desde:</strong><br/><input id='clientAddress' type='text' style='width:280px'> <input type='button' onclick='getDir(#lat#, #long#);' value='Ir'></p>";

var currentCount = 0;

function createCompanyMarker(company) {
    var contentString = "<div class=infoWindow>" + company.display + fromAddress.replace("#lat#", company.lat).replace("#long#", company.long) + "</div>";
    var marker = new google.maps.Marker({
        position: new google.maps.LatLng(company.lat, company.long),
        map: map,
        title: company.title,
        icon: new google.maps.MarkerImage("https://maps.google.com/mapfiles/ms/icons/" + company.icon + ".png")
    });

    google.maps.event.addListener(marker, 'click', function () {
        infowindow.setContent(contentString);
        infowindow.open(map, marker);
        infoWindows.push(infowindow);
    });

    currentCount++;
    document.getElementById("currentCount").innerHTML = currentCount.toString();

    //console.log(company.title + " " + marker.position);
    bounds.extend(marker.position);
}

function closeAllInfoWindows() {
    for (var i = 0; i < infoWindows.length; i++) {
        infoWindows[i].close();
    }
}

function setMarker(company) {
    if (company.lat == "") {
        var delay = (geoCodeCount * pause);
        if (geoCodeCount < 3) {
            delay = 100;
        }

        delayGeocode(company, delay);
    } else {
        createCompanyMarker(company);
    }
}

var overQueryLimit = 0;
var notFound = 0;
var notFoundAddresses = "";

function geoCode(company) {
    geocoder.geocode({ address: company.address }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            var p = results[0].geometry.location;
            company.lat = p.lat();
            company.long = p.lng();

            // Update the database so this
            // address doee not need to be geocoded
            // again
            updateAddress(company);

            createCompanyMarker(company);
        } else if (status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
            overQueryLimit++;
            document.getElementById("overlimit").innerHTML = overQueryLimit.toString();
        } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {

            company.lat = 9999;  //Magic number meaning unable to geocode
            company.long = 9999;

            // Update the database so this
            // address doee not need to be geocoded
            // again
            updateAddress(company);

            notFound++;
            document.getElementById("notFound").innerHTML = notFound.toString();
            notFoundAddresses += company.address + ", ";
        }
    })
}

function delayGeocode(company, delay) {
    setTimeout(function () {
        geoCode(company)
    }, delay);
}

function initialize() {
    infowindow = new google.maps.InfoWindow();
    geocoder = new google.maps.Geocoder();
    bounds = new google.maps.LatLngBounds();

    map = new google.maps.Map(document.getElementById("map-canvas"),
        {
            zoom: 10,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });

    google.maps.event.addListener(map, 'tilesloaded', function () {
        document.getElementById("pnlWait").style.display = "none";
    });

    document.getElementById("totalCompanies").innerHTML = companies.length.toString();

    for (var i = 0; i < companies.length; i++) {
        var company = companies[i];

        if (company.lat == "") {
            geoCodeCount++;
        }

        setMarker(company);
    }

    //var printControl = document.getElementById("mapPrint");
    //google.maps.event.addDomListener(printControl, 'click', function () {
    //    window.open("MapPrint.aspx");
    //});

    //map.controls[google.maps.ControlPosition.TOP_RIGHT].push(printControl);

    var printControlDiv = document.createElement('div');
    var printControl = new HomeControl(printControlDiv, map);
    printControlDiv.index = 1;
    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(printControlDiv);

    // Only delay if we have had to wait for
    // geocoding.
    var delay = 750;
    if (geoCodeCount > 0) {
        delay = (geoCodeCount * pause) + pause;
    }
    setTimeout(setCenter, delay);

    directionsService = new google.maps.DirectionsService();
    directionsDisplay = new google.maps.DirectionsRenderer({
        suppressMarkers: false
    });
    directionsDisplay.setMap(map);
    directionsDisplay.setPanel(document.getElementById("directionsPanel"));
}

function setCenter() {
    map.fitBounds(bounds);
}

function updateAddress(company) {
    PRCo.BBOS.UI.Web.AJAXHelper.SetAddressGeoCode(company.addressid, company.lat, company.long, OnSuccess, OnFailure);
}

function OnSuccess() {
    //alert("Hello");
}
function OnFailure(error) {
    alert(error);
}

google.maps.event.addDomListener(window, 'load', initialize);

function getDir(lat, long) {
    geocoder.geocode({
        'address': document.getElementById('clientAddress').value
    },

        function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                var origin = results[0].geometry.location;
                var destination = new google.maps.LatLng(lat, long);

                var request = {
                    origin: origin,
                    destination: destination,
                    travelMode: google.maps.DirectionsTravelMode.DRIVING
                };

                directionsService.route(request, function (response, status) {
                    if (status == google.maps.DirectionsStatus.OK) {
                        directionsDisplay.setDirections(response);
                    }
                });

            } else {
                document.getElementById('clientAddress').value =
                    "Las instrucciones no se pueden calcular en este momento.";
            }
        });
}

function HomeControl(controlDiv, map) {
    // Set CSS styles for the DIV containing the control
    // Setting padding to 5 px will offset the control
    // from the edge of the map.
    controlDiv.style.padding = '5px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.title = 'Imprimir';
    controlUI.ID = "btnPrint";
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '12px';
    controlText.style.paddingLeft = '4px';
    controlText.style.paddingRight = '4px';
    controlText.innerHTML = 'Imprimir';
    controlUI.appendChild(controlText);

    // Setup the click event listeners: simply set the map to Chicago.
    google.maps.event.addDomListener(controlUI, 'click', function () {
        closeAllInfoWindows();
        window.print();
    });
}
