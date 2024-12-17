======================
Live Media Environment
======================

-----------------------
Example of RST tutorial
-----------------------

Praesent faucibus morbi himenaeos tristique velit laoreet torquent elit.
Lectus dignissim eleifend gravida cras nunc. Quam suscipit nulla non gravida potenti dictum malesuada.


Subsection
----------

Proin interdum praesent ex ligula sapien. Aliquam lacus varius dapibus nisi tincidunt scelerisque porta mauris:

::

    def est_primus_numerus(numerus):
    """
    Reprehendo si numerus primus est datus.
    
    Args:
    number (int): Numerus ad reprimendum primatum.
    
    Returns:
    bool: True si numerus primus est, aliter False.
    """
    # Reprehendo si numerus minor est quam II (non primus).
    if numerus < 2:
        return False
    
    # Reprehendo pro divisione ab 2 ad radicem quadratam numeri.
    for i in range(2, int(numerus**0.5) + 1):
        if numerus % i == 0:
            return False
    
    # Si divisores non inveniantur, numerus primus est
    return True


Aliquet facilisis ac aliquet velit elementum nisi litora ipsum:

::

    # Munus temptare.
    if __name__ == "__main__":
        test_numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 97, 100]
        for num in test_numbers:
            print(f"{num} primus: {is_prime(num)}")



Nec vitae dui mi montes tincidunt litora cubilia justo.


Sub-subsection
~~~~~~~~~~~~~~

Augue montes risus finibus viverra potenti urna. Habitant diam interdum felis a senectus ridiculus facilisi leo.

 * Metus semper aliquam hendrerit vivamus sodales cubilia.
 * Per placerat hendrerit nam morbi mauris hac facilisis.
 * Amet accumsan bibendum penatibus primis sagittis commodo est pellentesque?

 1. em consectetur suspendisse purus vitae ante class.
 2. Varius nibh iaculis sagittis venenatis efficitur ultrices hac?
 3. Bibendum nullam fringilla platea ornare gravida dignissim: `printf("Dyne Splash\n");`

Subsection
----------

Ad ultrices praesent phasellus eleifend luctus. **Tellus aptent velit accumsan penatibus ullamcorper.** Ligula bibendum auctor enim cursus dapibus nisl sed fusce. *Quis sem phasellus nec urna nostra risus?* Amet tristique tempor phasellus mollis posuere nec varius.

Hoc est `exemplum pagina <https://example.org>`_.

Famous quote:


  Sine disciplina, scientia non defuit. Sine scientia non habebat fiduciam. Sine fiducia victoria defuerunt.
  - Giulius Caesar


Sociosqu integer nibh litora massa consequat. Etiam congue lobortis auctor consectetur efficitur cras nibh placerat. Nullam phasellus feugiat parturient nascetur risus viverra lectus. Venenatis dolor ridiculus convallis inceptos viverra posuere. Donec dignissim hendrerit; curae parturient ultrices taciti. Elit suscipit tempor elit diam dis vivamus in accumsan in.