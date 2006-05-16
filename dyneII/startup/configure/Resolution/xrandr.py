import os, popen2, sys

paths = os.environ.get('PATH', '/bin:/usr/bin').split(':')
paths += ['/sbin', '/usr/sbin', '/usr/local/sbin']
for p in paths:
	xrandr = os.path.join(p, 'xrandr')
	if os.access(xrandr, os.X_OK):
		break
else:
	raise Exception(
		_('The xrandr command is not installed. I looked in all '
		  'these directories:\n\n- ' + '\n- '.join(paths) + '\n\n'
		  "This probably means that resizing isn't supported on your "
		  'system. Try upgrading your X server.'))

class Setting:
	def __init__(self, line):
		bits = [b for b in line.split() if b]
		self.n = int(bits[0])
		self.width = int(bits[1])
		self.height = int(bits[3])
		self.phy_width = bits[5]
		self.phy_height = bits[7]
		self.res = []
		self.current_r = None
		for r in bits[9:]:
			if r.startswith('*'):
				self.current_r = int(r[1:])
				self.res.append(self.current_r)
			else:
				self.res.append(int(r))
	
	def __str__(self):
		return '%s x %s' % (self.width, self.height)

def get_settings():
	cout, cin = popen2.popen2([xrandr])
	cin.close()
	settings = []
	current = None
	for line in cout:
		if line[0] in ' *' and ' x ' in line:
			try:
				setting = Setting(line[1:].strip())
				settings.append(setting)
				if line[0] == '*':
					current = setting
			except Exception, ex:
				print >>sys.stderr, "Failed to parse line '%s':\n%s" % \
					(line.strip(), str(ex))
	cout.close()
	return (current, settings)

def set_mode(setting):
	cerr, cin = popen2.popen4([xrandr, '-s', str(setting.n)])
	cin.close()
	errors = cerr.read()
	if errors:
		rox.alert(_("Errors from xrandr: '%s'") % errors)
