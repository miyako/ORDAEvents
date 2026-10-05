INSERT INTO [Client] ( [ID] , [Name] , [Email] , [Date_Creation] )
VALUES
(295 , 'TECH SOLUTIONS INC' , 'contact@techsolutions.com' , '2026/03/11 00:00:00:00'),
(296 , 'SOPHIE MARTIN' , 'sophie.martin@email.com' , '2026/03/11 00:00:00:00'),
(297 , 'GLOBAL INDUSTRIES LTD' , 'procurement@global-ind.com' , '2026/03/11 00:00:00:00'),
(298 , 'JOHN''S WORKSHOP' , 'john.workshop@email.com' , '2026/03/11 00:00:00:00'),
(299 , 'INNOVATECH STARTUP' , 'hello@innovatech.io' , '2026/03/11 00:00:00:00');

INSERT INTO [Product] ( [ID] , [Name] , [Description] , [Price] , [Stock] , [minimumStock] )
VALUES
(838 , 'dell xps 15 laptop' , 'Professional laptop - Intel i7-13700H, 16GB RAM, 512GB SSD, 15.6" 4K display' , 1299 , 20 , 5),
(839 , 'hp probook 450' , 'Business laptop - Intel i5-12500H, 8GB RAM, 256GB SSD, 14" Full HD' , 699 , 8 , 5),
(840 , 'lenovo ideapad 3' , 'Entry-level laptop - AMD Ryzen 5, 8GB RAM, 512GB SSD, 15.6" HD' , 449 , 30 , 10),
(841 , 'hp z2 tower workstation' , 'Professional workstation - Intel Xeon, 32GB RAM, 1TB SSD, NVIDIA RTX A4000' , 2499 , 8 , 2),
(842 , 'apple macbook pro 14' , 'MacBook Pro 14" - M3 Pro chip, 18GB RAM, 512GB SSD, Liquid Retina XDR' , 1999 , 11 , 3),
(843 , 'dell ultrasharp 27" 4k' , '27" 4K UHD monitor - IPS panel, USB-C, height adjustable, 99% sRGB' , 449 , 20 , 10),
(844 , 'acer 24" full hd monitor' , '24" Full HD monitor - IPS panel, 75Hz, AMD FreeSync' , 129 , 50 , 15),
(845 , 'samsung odyssey 32" curved' , '32" curved QHD gaming monitor - 165Hz, 1ms, G-Sync compatible' , 399 , 19 , 5),
(846 , 'lg 34" ultrawide monitor' , '34" ultrawide QHD monitor - 21:9 aspect ratio, HDR10, USB-C' , 599 , 14 , 5),
(847 , 'logitech mx master 3s' , 'Premium wireless mouse - Ergonomic design, 8K DPI, multi-device connectivity' , 99 , 54 , 20),
(848 , 'logitech m185 wireless' , 'Wireless mouse - 1000 DPI, plug-and-play nano receiver' , 15 , 90 , 30),
(849 , 'keychron k8 mechanical' , 'Wireless mechanical keyboard - Hot-swappable switches, RGB backlight, Mac/PC' , 89 , 39 , 15),
(850 , 'logitech k380 wireless' , 'Multi-device wireless keyboard - Compact design, 2-year battery life' , 39 , 65 , 25),
(851 , 'logitech brio 4k webcam' , '4K webcam - HDR, autofocus, Windows Hello compatible, dual microphones' , 199 , 19 , 10),
(852 , 'jabra evolve2 65 headset' , 'Wireless headset - Active noise cancellation, 37-hour battery, UC certified' , 249 , 23 , 10),
(853 , 'hp laserjet pro m404dn' , 'Monochrome laser printer - 38ppm, duplex printing, network ready' , 349 , 7 , 3),
(854 , 'epson ecotank et-4850' , 'All-in-one inkjet printer - Print, scan, copy, fax, cartridge-free printing' , 499 , 12 , 3),
(855 , 'anker 10-port usb hub' , 'Powered USB 3.0 hub - 10 ports, 60W power adapter, individual switches' , 49 , 35 , 15),
(856 , 'caldigit ts4 thunderbolt 4' , 'Thunderbolt 4 dock - 18 ports, 98W charging, 8K display support' , 399 , 15 , 5),
(857 , 'samsung t7 1tb ssd' , 'Portable SSD - 1TB capacity, 1050MB/s read speed, USB 3.2 Gen 2' , 99 , 45 , 20);

INSERT INTO [Order] ( [ID] , [Date_Order] , [Date_Livraison] , [Statut] , [Price] , [Mode_Paiement] , [Comment] , [order_number] , [ID_Client] )
VALUES
(270 , '2026/03/11 00:00:00:00' , '2026/03/18 00:00:00:00' , 'In progress' , 9680 , 'bank transfer' , 'Complete office setup for new branch - 5 workstations' , 'CMD-2026-0001' , 295),
(271 , '2026/03/08 00:00:00:00' , '2026/03/15 00:00:00:00' , 'Validate' , 3046 , 'credit card' , 'Home office equipment' , 'CMD-2026-0002' , 296),
(272 , '2026/03/11 00:00:00:00' , '2026/03/25 00:00:00:00' , 'In progress' , 14223 , 'bank transfer' , 'Enterprise deployment - IT department refresh' , 'CMD-2026-0003' , 297),
(273 , '2026/03/06 00:00:00:00' , '2026/03/13 00:00:00:00' , 'Validate' , 4819 , 'credit card' , 'Additional accessories for team' , 'CMD-2026-0004' , 299),
(274 , '2026/03/11 00:00:00:00' , '2026/03/16 00:00:00:00' , 'In progress' , 587 , 'credit card' , 'Gaming/streaming setup upgrade' , 'CMD-2026-0005' , 296);

INSERT INTO [OrderLine] ( [ID] , [ID_Order] , [ID_Product] , [Quantity] )
VALUES
(519 , 270 , 838 , 5),
(520 , 270 , 843 , 5),
(521 , 270 , 847 , 5),
(522 , 270 , 849 , 5),
(523 , 271 , 842 , 1),
(524 , 271 , 846 , 1),
(525 , 271 , 851 , 1),
(526 , 271 , 852 , 1),
(527 , 272 , 840 , 2),
(528 , 272 , 844 , 2),
(529 , 272 , 839 , 10),
(530 , 272 , 843 , 10),
(531 , 272 , 848 , 10),
(532 , 272 , 850 , 10),
(533 , 272 , 853 , 3),
(534 , 273 , 851 , 8),
(535 , 273 , 852 , 8),
(536 , 273 , 855 , 5),
(537 , 273 , 857 , 10),
(538 , 274 , 845 , 1),
(539 , 274 , 849 , 1),
(540 , 274 , 847 , 1);
