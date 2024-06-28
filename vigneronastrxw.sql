-- BY ASTRXW https://discord.gg/ArxVYVfN

-- Ajouter le job 'vigneron'
INSERT INTO jobs (name, label, whitelisted) VALUES
('vigneron', 'Vigneron', 0);

INSERT INTO job_grades (job_name, grade, label, salary) VALUES
('vigneron', 0, 'Recrue', 200),
('vigneron', 1, 'Ouvrier', 400),
('vigneron', 2, 'Chef d équipe', 600),
('vigneron', 3, 'Manager', 800),
('vigneron', 4, 'Boss', 1000);

INSERT INTO items (name, label, weight) VALUES
('raisin', 'Raisin', 1),
('vine', 'Bouteille de vin', 1);