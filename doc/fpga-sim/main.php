<?php

error_reporting(-1);

require_once "iSIMD.interface.php";
require_once "Signal.class.php";
require_once "Memory.class.php";
require_once "SimdArray.class.php";
require_once "SimdNode.class.php";
require_once "SimdControll.class.php";

// Simulation Controls
$sleep = 2;

// Create SIMD nodes
$nodes 	= new SimdArray(5, 5);
$ctrl 	= new SimdControll();
$imem 	= new Memory("iMem", 1000, array(
	array("ctrl" => true,  "fn" => "foo"),
	array("ctrl" => true,  "fn" => "bar"),
	array("ctrl" => true,  "fn" => "exit"),
	array("ctrl" => false, "fn" => "print", 	"rs" => "rand"),
	array("ctrl" => false, "fn" => "storei",	"rs" => "r00", "c" => 100),
	array("ctrl" => false, "fn" => "add", 		"rs" => "rand", "rt" => "r00", "rd" => "r01"),
	array("ctrl" => false, "fn" => "print", 	"rs" => "r01")
));

// Simulate the processor
echo "Starting simulation!\n";
while (true) {
	// Simulate clock tick
	Signal::tick();
	
	$imem	->tick();
	$ctrl	->tick();
	// $nodes->tick();
	
	$imem	->run();
	$ctrl	->run();
	// $nodes->run();

	echo "sleep " . $sleep . "\n";
	sleep($sleep);
}

?>