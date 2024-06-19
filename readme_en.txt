Introduction
	This is an ASC16-style Mega ROM.
	It is ASC16-like, but not ASC16, so even if you write ASC16-type commercial game software to it, 
	it will not work properly in many cases, Please note that in many cases, it will not work properly.
	This is a MegaROM controller to run your own software, and is intended for those who want to make 
	it inexpensively with general-purpose parts.

Disclaimer
	No Warranty.
	I (t.hara) assume no responsibility for any defects or disadvantages that may result from the use 
	of this information.
	You are free to reproduce, modify, manufacture, distribute, and sell this information as long as 
	you agree to the terms of this agreement.
	Please check the operation of the software by yourself, and distribute or sell it under your own 
	responsibility.

Specifications
	4000-7FFF becomes BANK0 and 8000-BFFF becomes BANK1.
	A write to BANK0 is a write to the bank register of BANK1.
	A write to BANK1 is a write to ROM at the address indicated in the BANK1 bank register.
	Reading BANK0 reads BANK#0 in ROM.
	Reading BANK1 reads from ROM at the address indicated by the bank register of BANK1.
	There are 32 banks of ROM from BANK#0 to #31, each bank being 16 KB. 16 KB is separated from the top 
	of the 512 KB ROM, The ROM is allocated as BANK#0, BANK#1, ..., ..., BANK#31, and so on, starting 
	from the top. BANK#31 and so on from the top.

Differences from ASCII16
	(1) ASC16 can switch the bank of BANK0, but BANK0 is fixed to BANK#0 in this cartridge.
	(2) In ASC16, the bank of BANK1 is initialized to BANK#0 at reset, but the initial bank number 
	    is not fixed in this cartridge.
	    Be sure to initialize the bank number before accessing.
	(3) In ASC16, the bank register of BANK1 exists in 7000-77FF, but in this cartridge, 
	    4000-7FFF are all bank registers.

Concept
	Although 4000-7FFF is a bank register, if you use the 7000-77FF range, it will work as expected 
	if you set it as ASC16 when developing with emulators such as OpenMSX.
	Therefore, the design is based on ASC16, and only two general-purpose ICs are required.
	The concept of this Mega ROM is that development tools can be used without modification with a 
	small number of general-purpose ICs.

Substrate manufacturing
	(1) Open https://jlcpcb.com/ in your web browser.
	(2) Drag and drop the following file to Add Garber File
	  /pcb/simple_megarom_cartridge/simple_megarom_cartridge.zip
	(3) Then, simply follow the instructions on the site to complete the purchase procedure.

	The thickness of the board should be the default 1.6 mm.
	For the card edge connector portion of the cartridge, cut the corners of the board at an angle 
	using a file to make it easier to insert into the MSX.
	The component side of the cartridge is the front side (the side that is visible when the cartridge 
	is inserted into the MSX).
	Holes are drilled to fit the Konami type cartridge shell.
	Note that if you use an IC socket, it will not fit into the cartridge shell.

Writing to Flash ROM
	It can be written by using SMEGAWRT.COM in writer.
	On MSX-DOS,
	  >SMEGAWRT TARGET.ROM
	on MSX-DOS will write TARGET.ROM.

	ROM can be detached by toggling the switch on the cartridge.
	If you want to rewrite it to something else after writing it once, detach it at startup,
	After MSX-DOS is started up, the switch can be switched back to the connected state.
	If you do not need the switch, you can short-circuit the top two through-holes of the switch so 
	that the switch is always connected.

-------------------------------------------------------------------------------
June/ 9th/2024 1st release
June/19th/2024 append message

Copyright (C) 2024 t.hara (HRA!)
