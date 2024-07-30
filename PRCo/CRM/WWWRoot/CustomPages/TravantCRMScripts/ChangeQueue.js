function updatePerson() {

	var personID = document.querySelector('input[name="rbPersonID"]:checked');
	if (personID == null) {
		alert("Please select a person record to update.");
		return;
	}

	alert(personID.value);
}


function changeQueueConfirmApproveAll() {
	if (confirm("Are you sure you want to approve all changes?")) {
		document.EntryForm.HiddenMode.value = 'ApproveAll';
		document.getElementById("EntryForm").submit();
	}
	return false;
}

function changeQueueConfirmApproveSelected() {

	var anyBoxesChecked = false;
	$('#EntryForm input[type="checkbox"]').each(function () {
		if ($(this).is(":checked")) {
			anyBoxesChecked = true;
		}
	});

	if (!anyBoxesChecked) {
		alert("Please select changes to approve.");
		return;
	}

	if (confirm("Are you sure you want to approve the selected changes?")) {
		document.EntryForm.HiddenMode.value = 'ApproveSelected';
		document.getElementById("EntryForm").submit();
	}
	return false;
}

function changeQueueConfirmDeleteAll() {
	if (confirm("Are you sure you want to delete all changes?")) {
		document.EntryForm.HiddenMode.value = 'DeleteAll';
		document.getElementById("EntryForm").submit();
	}
	return false;
}

function changeQueueConfirmDeleteSelected() {

	var anyBoxesChecked = false;
	$('#EntryForm input[type="checkbox"]').each(function () {
		if ($(this).is(":checked")) {
			anyBoxesChecked = true;
		}
	});

	if (!anyBoxesChecked) {
		alert("Please select changes to delete.");
		return false;
	}

	if (confirm("Are you sure you want to delete the selected changes?")) {
		document.EntryForm.HiddenMode.value = 'DeleteSelected';
		document.getElementById("EntryForm").submit();
	}
	return false;
}