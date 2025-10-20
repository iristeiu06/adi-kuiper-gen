.. _hardware-configuration:

Hardware Configuration
======================

.. description::

   Configure Kuiper images for ADI evaluation boards and Raspberry Pi
   platforms with automated tools and manual options for flexible deployment

Kuiper supports multiple hardware platforms, each with different setup
requirements:

**ADI Evaluation Boards**
   Require configuration to specify which evaluation board and carrier
   combination you're using. This can be done during the build process or
   after deployment. Check out the :ref:`hardware-configuration-adi-eval-boards`
   dedicated section.

**Raspberry Pi**
   Works immediately after flashing with no configuration required. This
   section documents optional customizations like device tree overlays. Check 
   out the :ref:`hardware-configuration-raspberry-pi` dedicated section.

----

.. _hardware-configuration-adi-eval-boards:

ADI Evaluation Boards
---------------------

ADI evaluation boards require configuration to work with Kuiper images.
You must specify both your evaluation board (e.g., AD9361-FMCOMMS2) and
carrier platform (e.g., ZedBoard, ZC706) so the system can load the
correct boot files.

Kuiper provides flexible configuration options:

**Build-Time Configuration (Optional)**
   Set ``ADI_EVAL_BOARD`` and ``CARRIER`` parameters in your config file
   before building. Your image will be automatically configured for that
   hardware combination during the build process.

**Runtime Reconfiguration (Always Available)**
   Use the ``configure-setup.sh`` script to configure or reconfigure your
   image for different hardware combinations after deployment. This script
   is always installed and available.

**Key Benefits**

* Set defaults at build time for your primary hardware target
* Reconfigure anytime for testing different evaluation boards
* Use the same image across multiple hardware platforms
* No rebuilding required when switching hardware configurations

When to Configure Hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hardware configuration is useful when you need to:

* Set up your primary hardware during the build process for immediate use
* Test multiple evaluation boards with the same Kuiper installation
* Switch between development and production hardware without rebuilding
* Explore different ADI evaluation projects on various carrier boards
* Use a single image across multiple hardware setups

Common Workflows
~~~~~~~~~~~~~~~~

**Single Hardware Target**
   Set ``ADI_EVAL_BOARD`` and ``CARRIER`` during build for automatic
   configuration. Your image boots ready to use.

**Multi-Hardware Development**
   Build with your primary hardware configured, then use runtime
   reconfiguration to test other combinations as needed.

**Flexible Lab Image**
   Build without specifying hardware (leave ``ADI_EVAL_BOARD`` and
   ``CARRIER`` empty), then configure each deployment using the runtime
   script.

Automated Hardware Reconfiguration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The recommended method for configuring your Kuiper image is the
``configure-setup.sh`` script. This script handles all technical details
of copying files, updating configurations, and preparing your system for
different hardware combinations.

Discovering Available Hardware
++++++++++++++++++++++++++++++

Before reconfiguring, you need to know what combinations your Kuiper
image supports. The configuration script includes a discovery feature.

To see available hardware combinations:

.. shell::

   $sudo configure-setup.sh --help
    Usage:
      sudo configure-setup.sh [OPTIONS] [ARGUMENTS]

    Description:
      Script that prepares Kuiper image to boot on a carrier board.

    Arguments:
      eval-board	Name of the project
      carrier	Carrier board name

    Options:
      -h, --help	Show this help message

    Example:
      sudo configure-setup.sh ad4003 zed


    Available projects in your Kuiper image:

    ADI Eval Board    Carrier
    ad9361-fmcomms2   zed
    ad9361-fmcomms2   zc706
    ad4003            zed
    adrv9009-zu11eg   adrv9009-zu11eg-revb

This output shows all evaluation board and carrier combinations that your
specific Kuiper image supports.

Reconfiguration Process
+++++++++++++++++++++++

Hardware reconfiguration requires root access (the ``analog`` user has
sudo privileges) and that your system runs from an SD card or storage
device. The process varies depending on whether you're switching to
different physical hardware or reconfiguring for the same hardware.

Follow these steps:

#. **Log into your current Kuiper system** via console, SSH, or VNC.

#. **Check available configurations** (if you haven't already):

   .. shell::

      $sudo configure-setup.sh --help

#. **Run the configuration command** with your desired hardware
   combination:

   .. shell::

      $sudo configure-setup.sh <eval-board> <carrier>

   For example, to configure for AD9361-FMCOMMS2 on ZedBoard:

   .. shell::

      $sudo configure-setup.sh ad9361-fmcomms2 zed
       Successfully prepared boot partition for running project ad9361-fmcomms2 on zedboard.

#. **Shutdown your system** (for hardware changes) or **reboot** (for
   same hardware):

   For different hardware platforms:

   .. shell::

      $sudo shutdown -h now

   For same hardware reconfiguration:

   .. shell::

      $sudo reboot

#. **Move the SD card** (only if switching to different hardware):

   * Remove the SD card from your current hardware
   * Insert it into your target hardware platform
   * Skip this step if reconfiguring for the same hardware

#. **Boot your target system**:

   * Power on the target hardware
   * The system will boot with the new configuration

.. important::

   * Configuration changes take effect only after a complete boot cycle.
   * When switching between different carrier boards (e.g., ZedBoard to
     ZC706), physically move the SD card to the new hardware.
   * For same-hardware reconfigurations, use ``reboot`` instead of the
     full shutdown/move/boot process.
   * Always use ``shutdown -h now`` when moving to different physical
     hardware to ensure proper system state.

What Happens During Reconfiguration
+++++++++++++++++++++++++++++++++++

When you run the configuration script, it automatically handles all
technical details:

**File Management**
   The script identifies and copies all required files for your specific
   hardware combination, including kernels, device trees, and boot
   configurations.

**Platform Adaptation**
   Different hardware platforms require different boot procedures. The
   script handles these variations automatically, including special
   requirements for Intel-based systems.

**Verification and Feedback**
   The script reports success or failure for each operation, allowing you
   to confirm configuration completed properly before rebooting.

Configuration Examples
++++++++++++++++++++++

**Same Hardware Reconfiguration**

When testing different evaluation board projects on the same carrier
board, use the simple reboot workflow since no physical hardware changes:

.. shell::

   $sudo configure-setup.sh ad4003 zed
    Successfully prepared boot partition for running project ad4003 on zed.
   $sudo reboot

Later, switch to a different project:

.. shell::

   $sudo configure-setup.sh ad9361-fmcomms2 zed
    Successfully prepared boot partition for running project ad9361-fmcomms2 on zedboard.
   $sudo reboot

**Different Hardware Platforms**

When switching between different carrier boards, follow the complete
shutdown/move/boot workflow:

.. shell::

   $sudo configure-setup.sh ad9361-fmcomms2 zed
    Successfully prepared boot partition for running project ad9361-fmcomms2 on zedboard.
   $sudo shutdown -h now

After shutdown, remove the SD card from the ZedBoard and insert it into
your ZC706 carrier board, then power on the ZC706.

Later, reconfigure for the same project on ZC706:

.. shell::

   $sudo configure-setup.sh ad9361-fmcomms2 zc706
    Successfully prepared boot partition for running project ad9361-fmcomms2 on zc706.
   $sudo shutdown -h now

Again, move the SD card from ZC706 to your target hardware and power on.

**Development and Testing Workflow**

A common development workflow combines both scenarios - testing on
development hardware, then deploying to production hardware:

.. shell::

   # Development phase: test different projects on ZedBoard
   $sudo configure-setup.sh ad9361-fmcomms2 zed
   $sudo reboot

Run development tests, then:

.. shell::

   $sudo configure-setup.sh ad4003 zed
   $sudo reboot

When ready for production deployment:

.. shell::

   $sudo configure-setup.sh ad9361-fmcomms2 zc706
   $sudo shutdown -h now

Remove SD card from ZedBoard, insert into ZC706 production hardware, and
power on.

On production hardware, verify configuration:

.. shell::

   $sudo configure-setup.sh --help

Confirm your project shows in the available list.

Manual Configuration (Advanced)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While the automated ``configure-setup.sh`` script handles most
configuration scenarios, manual configuration may be necessary when:

* The automated script fails or reports errors
* You need custom modifications with specific file versions
* Your Kuiper system is not functioning and the script is unavailable
* You're working on a host PC to prepare SD cards before deployment
* You need to understand the boot process for development or debugging

The manual process involves the same file operations that the automated
script performs, but gives you direct control over each step.

Understanding What configure-setup.sh Does
++++++++++++++++++++++++++++++++++++++++++

For manual configuration, it helps to understand the technical process
that the automated script performs:

#. **Project Discovery**: Searches ``/boot`` for JSON files containing
   metadata about available hardware combinations, matching your
   specified evaluation board and carrier.

#. **File Selection**: Extracts file paths from the JSON metadata,
   identifying which kernel (Image/uImage/zImage), device tree, and boot
   files are needed for your specific hardware.

#. **Boot Partition Updates**: Copies all required files to ``/boot``,
   including platform-specific files like BOOT.BIN, device trees, and
   common files like kernel images and U-Boot configurations.

#. **Platform-Specific Operations**: For Intel platforms, creates
   extlinux directories and writes preloader files to the dedicated
   bootloader partition (typically ``/dev/mmcblk0p3``) using low-level
   disk operations.

#. **Validation**: Verifies each file operation completed successfully
   and reports any errors that would prevent proper booting.

Understanding these steps helps when performing manual configuration or
troubleshooting automated configuration failures.

Platform-Specific Manual Steps
++++++++++++++++++++++++++++++

.. important::

   Manual configuration requires working with the SD card's boot
   partition. Always ensure the SD card is properly unmounted from your
   target hardware before modifying files on a host PC.

.. note::

   If required boot files are missing from your Kuiper image, install
   them using the ADI package repository. See the :doc:`Repositories
   <repositories>` section for detailed instructions.

AMD/Xilinx Platforms
....................

**For Zynq projects** (ZedBoard, ZC702, ZC706), copy these files to the
root of the BOOT FAT32 partition:

#. ``<target>/BOOT.BIN`` - First stage bootloader with FPGA bitstream
#. ``<target>/<specific_folder>/devicetree.dtb`` - Device tree for your
   specific project
#. ``zynq-common/uImage`` - Kernel image for Zynq platforms
#. ``zynq-common/uEnv.txt`` - U-Boot environment configuration

**For ZynqMP projects** (ZCU102, ADRV9009-ZU11EG), copy these files to
the root of the BOOT FAT32 partition:

#. ``<target>/BOOT.BIN`` - First stage bootloader with FPGA bitstream
#. ``<target>/<specific_folder>/system.dtb`` - Device tree for your
   specific project
#. ``zynqmp-common/Image`` - Kernel image for ZynqMP platforms
#. ``zynqmp-common/uEnv.txt`` - U-Boot environment configuration

**For Versal projects** (VCK190, VPK180, VHK158), copy these files to the root
of the BOOT FAT32 partition:

#. ``<target>/BOOT.BIN`` - Platform Loader and Manager (PLM) and boot
   components
#. ``<target>/<specific_folder>/system.dtb`` - Device tree for your
   specific project
#. ``<target>/boot.scr`` - U-Boot script for Versal boot sequence
#. ``versal-common/Image`` - Kernel image for Versal platforms

Intel/Altera Platforms
......................

Intel platforms require additional steps beyond copying files to the boot
partition. You must also write preloader files to a dedicated bootloader
partition.

**For Arria10 SoC projects**, copy these files to the root of the BOOT
FAT32 partition:

#. ``<target>/fit_spl_fpga.itb`` - FPGA configuration and SPL image
#. ``<target>/socfpga_arria10_socdk_sdmmc.dtb`` - Device tree
#. ``<target>/u-boot.img`` - U-Boot proper
#. ``socfpga_arria10_common/zImage`` - Kernel image
#. Create an ``extlinux`` folder and copy
   ``socfpga_arria10_common/extlinux.conf`` into it

Then write the preloader:

.. shell::

   $sudo dd if=<target>/fit_spl_fpga.itb of=/dev/mmcblk0p3 bs=512 status=progress

Replace ``mmcblk0p3`` with your actual bootloader partition device.

**For Cyclone5 projects** (DE10-Nano, Cyclone V SoC Kit), copy these
files to the root of the BOOT FAT32 partition:

#. ``<target>/soc_system.rbf`` - FPGA bitstream
#. ``<target>/socfpga.dtb`` - Device tree
#. ``<target>/u-boot.scr`` - U-Boot script
#. ``<target>/u-boot-with-spl.sfp`` - SPL and U-Boot combined
#. ``socfpga_cyclone5_common/zImage`` - Kernel image
#. Create an ``extlinux`` folder and copy
   ``socfpga_cyclone5_common/extlinux.conf`` into it

Then write the preloader:

.. shell::

   $sudo dd if=<target>/u-boot-with-spl.sfp of=/dev/mmcblk0p3 bs=512 status=progress

Replace ``mmcblk0p3`` with your actual bootloader partition device.

Finding the Bootloader Partition
................................

For Intel platforms, identify the correct partition for the preloader.

.. shell::

   $lsblk

Example output on PC:

.. shell::
   :no-path:

   $lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sdb      8:16   1  29.7G  0 disk
    ├─sdb1   8:17   1   256M  0 part /media/user/BOOT
    ├─sdb2   8:18   1  29.2G  0 part /media/user/rootfs
    └─sdb3   8:19   1     4M  0 part

In this case, ``/dev/sdb3`` is the 4MB bootloader partition.

Example output on target board:

.. shell::
   :no-path:

   $lsblk
    NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    mmcblk0     179:0    0 29.7G  0 disk
    ├─mmcblk0p1 179:1    0  256M  0 part /mnt/BOOT
    ├─mmcblk0p2 179:2    0 29.2G  0 part
    └─mmcblk0p3 179:3    0    4M  0 part

In this case, ``/dev/mmcblk0p3`` is the 4MB bootloader partition.

----

.. _hardware-configuration-raspberry-pi:

Raspberry Pi
------------

Raspberry Pi images work out-of-box without configuration. The SD card
boots immediately after flashing - no setup required.

This section covers optional customizations you can make after your
system is running.

Device Tree Overlays
~~~~~~~~~~~~~~~~~~~~

Raspberry Pi uses device tree overlays to enable additional hardware
features or configure peripherals. There are two methods to load
overlays.

Method 1: Persistent Configuration
++++++++++++++++++++++++++++++++++

Edit ``/boot/config.txt`` to automatically load overlays on every boot.

#. Open the configuration file and add a new line with your overlay:

   .. code-block:: text

      dtoverlay=<overlay_name>[,<overlay_arguments>]

   For example:

   .. code-block:: text

      dtoverlay=spi0-1cs

#. Save the file and reboot:

   .. shell::

      $sudo reboot

Changes take effect after reboot.

Method 2: Dynamic Loading
+++++++++++++++++++++++++

Load overlays at runtime without rebooting or modifying configuration
files. Raspberry Pi package ``libraspberrypi-bin`` needs to be installed for
this method.

.. shell::

   $sudo dtoverlay <overlay_name>[,<overlay_arguments>]

For example:

.. shell::

   $sudo dtoverlay spi0-1cs

.. note::

   Dynamically loaded overlays are lost on reboot. Use Method 1 for
   permanent configuration.

Available Overlays
~~~~~~~~~~~~~~~~~~

Overlay binaries (``*.dtbo``) are located in ``/boot/overlays``.

To list available overlays:

.. shell::

   $ls /boot/overlays/
    rpi-ad7091r8.dtbo
    rpi-ad7124-8-all-diff.dtbo
    rpi-ad7124.dtbo
    rpi-ad7173.dtbo
    rpi-ad7190.dtbo
    rpi-ad7191.dtbo
    rpi-ad7293.dtbo
    ...

.. important::

   Specify only the overlay name without extension or path. For example,
   use ``dtoverlay=my-overlay`` not
   ``dtoverlay=/boot/overlays/my-overlay.dtbo``.

Common Overlay Use Cases
~~~~~~~~~~~~~~~~~~~~~~~~

Here are typical scenarios for using device tree overlays:

**Enable SPI Interface**

.. shell::

   $sudo dtoverlay spi0-1cs

Or in ``/boot/config.txt``:

.. code-block:: text

   dtoverlay=spi0-1cs

**Load ADI Evaluation Board Overlay**

For ADI-specific overlays (assuming they exist in ``/boot/overlays``):

.. shell::

   $sudo dtoverlay rpi-ad7191

Or in ``/boot/config.txt``:

.. code-block:: text

   dtoverlay=rpi-ad7191

Removing Overlays
~~~~~~~~~~~~~~~~~

To remove a dynamically loaded overlay:

.. shell::

   $sudo dtoverlay -r <overlay_name>

For overlays in ``/boot/config.txt``, comment out or delete the line and
reboot.
