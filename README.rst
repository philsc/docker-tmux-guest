docker-tmux-guest
=================

This docker project is meant to make it easy to share a tmux session with 
others. It opens a port (default 999) that others can SSH into and 
automatically be part of your session.


Pre-requisites
==============

- Install docker

- Install tmux


Usage
=====

1. Clone this repo

   .. code:: sh

     git clone https://github.com/philsc/docker-tmux-guest.git
     cd docker-tmux-guest

2. Build docker image

   .. code:: sh

     docker build -t tmux-guest:latest .

3. Run the helper script to start up tmux, docker and connect the two together.

   .. code:: sh

     ./run.sh

   The helper script will print a bunch of information that you can use to 
   share the tmux session with others.

4. Attach to the tmux session with the socket that was printed in the helper 
   script. For example, if the helper script says that the tmux socket is 
   located at ``/tmp/tmp.abcdef/tmux-guest-port-999`` then you can attach to 
   the session like so:

   .. code:: sh

     tmux -S /tmp/tmp.abcdef/tmux-guest-port-999 attach

5. Have others join your session by SSHing into the specified port as the 
   ``guest`` user.

   .. code:: sh

     ssh -p 999 guest@IPADDRESS

   where you replace ``IPADDRESS`` above with the IP address of your machine.

6. When you're done sharing the screen, simply disconnect from tmux and run the 
   following command to kill the docker instance:

   .. code:: sh

     docker kill tmux-guest-port-999

   The helper script will then kill the tmux session and cleanup the temporary 
   files it had created.


Issues/Restrictions
===================

- This will only work on a Linux system with a sufficiently recent kernel. This 
  is inherent to using docker.

- The read-only guest sessions still have the authority to resize the tmux 
  window. This is kind of annoying if you, the presenter, want to work with a 
  certain minimum size. The only way to avoid this right now would be to 
  manually re-compile tmux with the following change

  .. code:: diff

    diff --git a/resize.c b/resize.c
    index 5c365df..dab4508 100644
    --- a/resize.c
    +++ b/resize.c
    @@ -58,7 +58,7 @@ recalculate_sizes(void)
            ssx = ssy = UINT_MAX;
            for (j = 0; j < ARRAY_LENGTH(&clients); j++) {
                c = ARRAY_ITEM(&clients, j);
    -            if (c == NULL || c->flags & CLIENT_SUSPENDED)
    +            if (c == NULL || c->flags & (CLIENT_SUSPENDED | CLIENT_READONLY))
                     continue;
                 if (c->session == s) {
                     if (c->tty.sx < ssx)


Inspiration
===========
The vast majority of this work was originally inspired by the following article 
by Brian McKenna: http://brianmckenna.org/blog/guest_tmux
